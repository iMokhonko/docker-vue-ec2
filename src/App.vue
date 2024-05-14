<template>
  <!-- <nav>
    <router-link to="/">Home v5</router-link> |
    <router-link to="/about">About v5</router-link>
  </nav> -->

  <PageHeader />

  <div class="page">
    <div class="page__channels">
      <div class="page__channels-header">
        <div class="page__channels-header-title">
          <h2>Channels</h2>
          <!--<button class="create-channel-button">+</button>-->
        </div>
        <input
          placeholder="Search people"
        >
      </div>

      <div class="page__channels-inner">
        <ChatItem
          v-for="(channel, index) in sortedChannels"
          :key="index"
          :name="channel.name"
          :is-active="activeChannel === channel.id"
          :unread-messages-count="channel.unreadMessagesCount"
          :is-own-message="channel.isOwnMessage"
          :last-message-text="channel.lastMessageText"
          :last-message-time="channel.lastMessageTime"
          :is-online="channel.isOnline"
          @click="activeChannel = channel.id"
        />
      </div>
    </div>

    <div class="page__channel">
      <div v-if="activeChannel" class="page__channel-header">
        <div class="avatar" :style="{ backgroundColor: getAvatarColor(currentChatUser.name) }">{{ getAvatarChars(currentChatUser.name) }}</div>
        <div class="name">{{ currentChatUser.name  }}</div>
        <div class="status online">online</div>
      </div>

      <div class="page__channel-inner">
        <button 
          v-if="chatMessages?.[activeChannel]?.bucketKey"
          @click="() => loadConversationPreviousMessages(activeChannel)"
        >
          Load previous messages
        </button>

        <div 
          v-if="activeChannel"
          ref="messagesContainer"
          class="messages-container"
        >
          <MessageItem
            v-for="(message, index) in (chatMessages?.[activeChannel]?.messages ?? [])"
            :key="index"
            :name="message.from"
            :message-text="message.text"
            :message-time="message.time"
            @hook:mounted="handleMessageMount"
          />
        </div>

        <div 
          v-if="activeChannel"
          class="input-container"
        >
          <input 
            v-model="message" 
            placeholder="Write a message..."
            @keyup.enter="() => sendMessageTo(activeChannel)"
          >
          <button @click="() => sendMessageTo(activeChannel)">
            send
          </button>
        </div>
      </div>
    </div>
  </div>  
</template>

<script>
// import { io } from "socket.io-client";
import { computed, defineComponent, ref, watch } from "vue";

import PageHeader from '@/components/PageHeader';
import ChatItem from '@/components/ChatItem';
import MessageItem from '@/components/MessageItem';

import io from 'socket.io-client';

import generageColorBasedOnChars from '@/helpers/generate-color-based-on-chars';

const emitAsync = (socket, name, payload) => new Promise(resolve => socket.emit(name, payload, resolve));

export default defineComponent({
  components: {
    PageHeader,
    ChatItem,
    MessageItem
  },

  setup() {
    const connectUrl = new URL(window.location).searchParams.get('c');
    const userId =  new URL(window.location).searchParams.get('userId');

    const message = ref('');
    const chatMessages = ref({});
    const messagesContainer = ref(null);

    const socket = io(connectUrl, { 
      withCredentials: true,
      auth: { userId }
    });

    socket.on('connect', () => console.log(`connected to -> ${connectUrl}`));
    socket.on("disconnect", (reason, details) => console.log(`disconnected from -> ${connectUrl}`, reason, details));

    const upsertChat = (payload) => {
      const channelIndex = channels.value.findIndex(({ id }) => id === payload.conversationId);

      if(!chatMessages.value[payload.conversationId]) {
        chatMessages.value[payload.conversationId] = {
          messages: [],
          bucketKey: null,
          paginationToken: null
        };
      }

      chatMessages.value[payload.conversationId].messages.push({
        from: payload.messageData.from,
        text: payload.messageData.messageText,
        time: payload.messageData.messageTime
      });

      if(channelIndex !== -1) {
        channels.value[channelIndex].isOwnMessage = payload.messageData.from === userId;
        channels.value[channelIndex].lastMessageText = payload.messageData.messageText;
        channels.value[channelIndex].lastMessageTime = payload.messageData.messageTime;
      } else {
        channels.value.push({
          id: payload.conversationId,
          name: payload.to,
          unreadMessagesCount: 0,
          isOnline: false,
          isOwnMessage: payload.messageData.from === userId,
          lastMessageText: payload.messageData.messageText,
          lastMessageTime: payload.messageData.messageTime
        })
      }
    }

    const sendMessageTo = async (to) => {
      const normalizedMessage = message.value.trim();

      if(!normalizedMessage.length) return;

      message.value = '';

      const result = await emitAsync(
        socket,
        'post-message-to-user',
        { 
          to: to.replace(userId, '').replace(':', ''),
          text: normalizedMessage
        }
      );
      

      upsertChat(result);
      
      return result;
    };

    const handleMessageMount = () => messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight;

    const loadConversationMessages = async (conversationId, { bucketKey = Date.now(), paginationToken = null, limit = 50 } = {}) => {
      const { 
        messages,
        paginationToken: nextPaginationToken,
        bucketKey: nextBucketKey
      } = await emitAsync(
        socket,
        'get-conversation-messages',
        { conversationId, bucketKey, paginationToken, limit }
      );

      if(chatMessages.value[conversationId]) {
        chatMessages.value[conversationId].bucketKey = nextBucketKey;
        chatMessages.value[conversationId].paginationToken = nextPaginationToken;
        chatMessages.value[conversationId].messages = [
          ...messages.reverse(),
          ...chatMessages.value[conversationId].messages,
        ]
      } else {
        chatMessages.value[conversationId] = {
          messages: [...messages].reverse(),
          bucketKey: nextBucketKey,
          paginationToken: nextPaginationToken
        }
      }
    };

    const loadConversationPreviousMessages = async (conversationId) => {
      await loadConversationMessages(
        conversationId,
        {
          bucketKey: chatMessages.value[conversationId].bucketKey,
          paginationToken: chatMessages.value[conversationId].paginationToken
        }
      );
    };

    socket.on('incoming-message', upsertChat);
    socket.on('update-user-chats', 
      (payload) => channels.value = payload.map(({ conversationId, to, lastMessageData }) => ({
        id: conversationId,
        name: to,
        unreadMessagesCount: 0,
        isOnline: false,
        lastMessageText: lastMessageData.messageText,
        lastMessageTime: lastMessageData.messageTime
      }))
    );

    const activeChannel = ref(null);
    const channels = ref([]);

    const sortedChannels = computed(() => [...channels.value].sort((a, b) => b.lastMessageTime - a.lastMessageTime))

    const currentChatUser = computed(() => {
      const userData = sortedChannels.value.find(({ id }) => id === activeChannel.value);

      return userData ?? null;
    });

    const getAvatarChars = (name) => {
			const words = name.split('.');

			return words.map(word => word[0].toUpperCase()).join('');
		};

    const getAvatarColor = (name) =>  generageColorBasedOnChars(name);

    watch(activeChannel, (conversationId) => loadConversationMessages(conversationId));
    

    return {
      message,
      chatMessages,
      messagesContainer,

      sortedChannels,
      activeChannel,
      currentChatUser,

      loadConversationMessages,
      loadConversationPreviousMessages,
      handleMessageMount,
      sendMessageTo,

      getAvatarChars,
      getAvatarColor
    }
  }
})
</script>

<style lang="scss">
html, body {
  padding: 0;
  margin: 0;
  height: 100%;
  width: 100%;
  max-height: 100%;
  max-width: 100%;
}

* {
  box-sizing: border-box;
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
}

#app {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  max-height: 100%;
  max-width: 100%;
  overflow: hidden;
}

.page {
  padding: 16px;
  display: flex;
  width: 100%;
  flex-grow: 1;
  overflow: hidden;
  padding-left: 0;
  padding-bottom: 0;

  &__channels {
    height: 100%;
    width: 400px;
    flex-shrink: 0;
    display: flex;
    flex-direction: column;
    row-gap: 16px;

    &-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      column-gap: 16px;
      padding-right: 8px;

      input {
        width: 200px;
        border-color: rgba(0, 95, 177, 0.08);
        padding: 4px 8px;
        border-radius: 4px;
      }

      &-title {
        display: flex;
        align-items: center;
        column-gap: 8px;
      }
    }

    h2 {
      margin: 0;
      font-weight: bold;
      margin-left: 16px;
    }

    &-inner {
      border-radius: 4px;
      flex-grow: 1;
      display: flex;
      flex-direction: column;
      overflow: auto;
      padding-right: 8px;
    }
  }

  &__channel {
    height: 100%;
    flex-grow: 1;
    display: flex;
    flex-direction: column;
    row-gap: 16px;
    padding-bottom: 16px;

    &-header {
      display: flex;
      align-items: center;
      column-gap: 8px;
      padding: 0 16px;
    }

    &-inner {
      background: rgba(0, 95, 177, 0.08);
      border-radius: 4px;
      flex-grow: 1;
      display: flex;
      flex-direction: column;
      row-gap: 16px;
      overflow: hidden;
    }
  }
}

.avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 12px;
  color: #fff;
}

.name {
  font-weight: bold;
}

.status {
  font-size: 12px;
  color: grey;

  &.online {
    color: green;
  }
}

.input-container {
  padding: 16px;
  display: flex;
  column-gap: 16px;
  padding-top: 0;
  margin-top: auto;

  input {
    flex-grow: 1;
    padding: 8px;
    resize: vertical;
    max-height: 200px;
  }

  button {
    width: 100px;
  }
}

.messages-container {
  padding: 16px;
  overflow: auto;
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  row-gap: 24px;

  .message {
    max-width: calc(100% - 16px);

    &:first-child {
      margin-top: auto;
    }
  }
}

.time {
  font-size: 10px;
  color: grey;
  font-weight: normal;
}

.create-channel-button {
  width: 24px;
  height: 24px;
  border: none;
  border-radius: 50%;
  background: rgba(0, 95, 177, 0.08);
  font-weight: bold;
  cursor: pointer;
}
</style>
