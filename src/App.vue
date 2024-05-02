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
          v-for="(channel, index) in channels"
          :key="index"
          :name="channel.name"
          :is-active="activeChannel === channel.id"
          :unread-messages-count="channel.unreadMessagesCount"
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
        <div class="messages-container">
          <MessageItem
            v-for="(message, index) in messages"
            :key="index"
            :name="message.name"
            :message-text="message.messageText"
            :message-time="message.messageTime"
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
import { defineComponent, ref } from "vue";

import PageHeader from '@/components/PageHeader';
import ChatItem from '@/components/ChatItem';
import MessageItem from '@/components/MessageItem';

import io from 'socket.io-client'

export default defineComponent({
  components: {
    PageHeader,
    ChatItem,
    MessageItem
  },

  setup() {
    const connectUrl = new URL(window.location).searchParams.get('c');

    const socket = io(connectUrl, { withCredentials: true });

    socket.on('connect', () => console.log(`connected to -> ${connectUrl}`));
    socket.on("disconnect", (reason, details) => console.log(`disconnected from -> ${connectUrl}`, reason, details));

    window.socket = socket;


    const activeChannel = ref(null);
    const channels = ref([
      {
        id: '1',
        name: 'Ivan Mokhonko',
        unreadMessagesCount: 1,
        isOnline: true,
        lastMessageText: 'Pellentesque libero tortor tincidunt et',
        lastMessageTime: Date.now()
      },
      {
        id: '2',
        name: 'Vasya Pupkin',
        unreadMessagesCount: 0,
        lastMessageText: 'Maecenas ullamcorper dui et placerat',
        lastMessageTime: Date.now()
      },
      {
        id: '3',
        name: 'Jeff Bezos',
        unreadMessagesCount: 5,
        lastMessageText: 'Phasellus gravida semper nisi. Vestibulum eu odio. Phasellus ullamcorper ipsum rutrum nunc. Suspendisse potenti. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc.',
        lastMessageTime: Date.now()
      },
      {
        id: '4',
        name: 'Mark Whalberg',
        unreadMessagesCount: 0,
        lastMessageText: 'Nullam vel sem. Donec mollis hendrerit risus. Phasellus tempus. Curabitur a felis in nunc fringilla tristique. Nam pretium turpis et arcu.',
        lastMessageTime: Date.now()
      },
      {
        id: '34234',
        name: 'Tom Cruz',
        isOnline: true,
        unreadMessagesCount: 0,
        lastMessageText: 'Nullam vel sem. Donec mollis hendrerit risus. Phasellus tempus. Curabitur a felis in nunc fringilla tristique. Nam pretium turpis et arcu.',
        lastMessageTime: Date.now()
      },
      {
        id: '5',
        name: 'Ivan Mokhonko',
        unreadMessagesCount: 0,
        lastMessageText: 'Pellentesque libero tortor tincidunt et',
        lastMessageTime: Date.now()
      },
      {
        id: '6',
        name: 'Vasya Pupkin',
        unreadMessagesCount: 0,
        lastMessageText: 'Maecenas ullamcorper dui et placerat',
        lastMessageTime: Date.now()
      },
      {
        id: '7',
        name: 'Jeff Bezos',
        unreadMessagesCount: 0,
        lastMessageText: 'Phasellus gravida semper nisi. Vestibulum eu odio. Phasellus ullamcorper ipsum rutrum nunc. Suspendisse potenti. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc.',
        lastMessageTime: Date.now()
      },
      {
        id: '8',
        name: 'Mark Whalberg',
        unreadMessagesCount: 0,
        lastMessageText: 'Nullam vel sem. Donec mollis hendrerit risus. Phasellus tempus. Curabitur a felis in nunc fringilla tristique. Nam pretium turpis et arcu.',
        lastMessageTime: Date.now()
      },
      {
        id: '4',
        name: 'Tom Cruz',
        unreadMessagesCount: 0,
        lastMessageText: 'Nullam vel sem. Donec mollis hendrerit risus. Phasellus tempus. Curabitur a felis in nunc fringilla tristique. Nam pretium turpis et arcu.',
        lastMessageTime: Date.now()
      }
    ]);

    const messages = [
      {
        id: '1',
        name: 'Ivan Mokhonko',
        messageText: `Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Sed in libero ut nibh placerat accumsan. Nullam sagittis. Praesent nec nisl a purus blandit viverra. Aliquam lobortis.

Mauris sollicitudin fermentum libero. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Maecenas vestibulum mollis diam. Nam at tortor in tellus interdum sagittis. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci.

Curabitur turpis. Aenean ut eros et nisl sagittis vestibulum. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Sed magna purus, fermentum eu, tincidunt eu, varius ut, felis. Nunc egestas, augue at pellentesque laoreet, felis eros vehicula leo, at malesuada velit leo quis pede.

Praesent egestas tristique nibh. Praesent ut ligula non mi varius sagittis. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Sed lectus. Aliquam erat volutpat.`,
        messageTime: Date.now()
      },
      {
        id: '2',
        name: 'Ivan Mokhonko',
        messageText: 'Nam pretium turpis et arcu. Sed mollis, eros et ultrices tempus, mauris ipsum aliquam libero, non adipiscing dolor urna a orci. Vivamus quis mi. Nulla facilisi. Nunc sed turpis.',
        messageTime: Date.now()
      },
      {
        id: '3',
        name: 'Ivan Mokhonko',
        messageText: `Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Sed in libero ut nibh placerat accumsan. Nullam sagittis. Praesent nec nisl a purus blandit viverra. Aliquam lobortis.

Mauris sollicitudin fermentum libero. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Maecenas vestibulum mollis diam. Nam at tortor in tellus interdum sagittis. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci.

Curabitur turpis. Aenean ut eros et nisl sagittis vestibulum. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Sed magna purus, fermentum eu, tincidunt eu, varius ut, felis. Nunc egestas, augue at pellentesque laoreet, felis eros vehicula leo, at malesuada velit leo quis pede.

Praesent egestas tristique nibh. Praesent ut ligula non mi varius sagittis. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Sed lectus. Aliquam erat volutpat.`,
        messageTime: Date.now()
      },
      {
        id: '4',
        name: 'Ivan Mokhonko',
        messageText: 'Nam pretium turpis et arcu. Sed mollis, eros et ultrices tempus, mauris ipsum aliquam libero, non adipiscing dolor urna a orci. Vivamus quis mi. Nulla facilisi. Nunc sed turpis.',
        messageTime: Date.now()
      },
      {
        id: '5',
        name: 'Ivan Mokhonko',
        messageText: 'Nam pretium turpis et arcu. Sed mollis, eros et ultrices tempus, mauris ipsum aliquam libero, non adipiscing dolor urna a orci. Vivamus quis mi. Nulla facilisi. Nunc sed turpis.',
        messageTime: Date.now()
      },
      {
        id: '6',
        name: 'Ivan Mokhonko',
        messageText: `Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Sed in libero ut nibh placerat accumsan. Nullam sagittis. Praesent nec nisl a purus blandit viverra. Aliquam lobortis.

Mauris sollicitudin fermentum libero. Donec elit libero, sodales nec, volutpat a, suscipit non, turpis. Maecenas vestibulum mollis diam. Nam at tortor in tellus interdum sagittis. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci.

Curabitur turpis. Aenean ut eros et nisl sagittis vestibulum. Aenean tellus metus, bibendum sed, posuere ac, mattis non, nunc. Sed magna purus, fermentum eu, tincidunt eu, varius ut, felis. Nunc egestas, augue at pellentesque laoreet, felis eros vehicula leo, at malesuada velit leo quis pede.

Praesent egestas tristique nibh. Praesent ut ligula non mi varius sagittis. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Sed lectus. Aliquam erat volutpat.`,
        messageTime: Date.now()
      }
    ];

    return {
      channels,
      activeChannel,
      messages
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
