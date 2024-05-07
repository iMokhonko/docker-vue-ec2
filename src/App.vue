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
          <button class="create-channel-button">+</button>
        </div>
        <input
          placeholder="Search people or channels"
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
      <div class="page__channel-header">
        <div class="avatar">IM</div>
        <div class="name">Ivan Mokhonko</div>
        <div class="status online">online</div>
      </div>

      <div class="page__channel-inner">
        <div class="messages-container" v-if="activeChannel">
          <MessageItem
            v-for="(message, index) in chatMessages[activeChannel]"
            :key="index"
            :name="message.from"
            :message-text="message.text"
            :message-time="message.time"
          />
        </div>

        <div class="input-container">
          <textarea rows="1" placeholder="Write a message..."></textarea>
          <button>send</button>
        </div>
      </div>
    </div>
  </div>  

  <!-- <router-view/> -->
</template>

<script>
// import { io } from "socket.io-client";
import { computed, defineComponent, ref, watch } from "vue";

import PageHeader from '@/components/PageHeader';
import ChatItem from '@/components/ChatItem';
import MessageItem from '@/components/MessageItem';

import io from 'socket.io-client';

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

    const chatMessages = ref({});

    const socket = io(connectUrl, { 
      withCredentials: true,
      auth: { userId }
    });

    socket.on('connect', () => console.log(`connected to -> ${connectUrl}`));
    socket.on("disconnect", (reason, details) => console.log(`disconnected from -> ${connectUrl}`, reason, details));

    const upsertChat = (payload) => {
      const channelIndex = channels.value.findIndex(({ id }) => id === payload.conversationId);

      if(!chatMessages.value[payload.conversationId]) {
        chatMessages.value[payload.conversationId] = [];
      }

      chatMessages.value[payload.conversationId].push({
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

    window.sendMessageTo = async (to, text) => {
      const result = await emitAsync(
        socket,
        'post-message-to-user',
        { to, text }
      );

      upsertChat(result);
      
      return result;
    };

    const openConversation = async (conversationId, { date = Date.now(), paginationToken = null } = {}) => {
      const { result } = await emitAsync(
        socket,
        'get-conversation-messages',
        { conversationId, date, paginationToken }
      );


      if(chatMessages.value[conversationId]) {
        chatMessages.value[conversationId] = [
          ...result,
          ...chatMessages.value[conversationId].reverse(),
        ]
      } else {
        chatMessages.value[conversationId] = [...result].reverse();
      }
    };

    window.openConversation = openConversation;
   

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

    watch(activeChannel, (channelId) => openConversation(channelId));

    return {
      chatMessages,

      sortedChannels,
      activeChannel
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
  background: #4ADBC8;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 12px;
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

  textarea {
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
