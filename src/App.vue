<template>
  <!-- <nav>
    <router-link to="/">Home v5</router-link> |
    <router-link to="/about">About v5</router-link>
  </nav> -->

  <input v-model="joinRoomName" placeholder="Room name" @keyup.enter="joinRoom">
  <button @click="joinRoom">join</button>

  <div class="rooms">
    <div 
      v-for="(joinedRoomName, index) in joinedRooms"
      :key="index"
      class="room-container"
    >
      <div>
        <b>{{ joinedRoomName }}</b> <button @click="() => leaveRoom(joinedRoomName)">X</button>
      </div>

      <hr>

      <div class="room-messages">
        <div
          v-for="({ name, text }, index) in messages[joinedRoomName]"
          :key="index"
        >
          <b>{{ name }}</b>: {{ text }}
        </div>
      </div>

      <div>
        <input v-model="message" placeholder="Write your message..." @keyup.enter="sendMessage">
        <button @click="() => sendMessage(joinedRoomName)">send</button>
      </div>
    </div>
  </div>

  <!-- <router-view/> -->
</template>

<script>
import { io } from "socket.io-client";
import { defineComponent, ref } from "vue";

export default defineComponent({
  setup() {
    const connectUrl = new URL(window.location).searchParams.get('c');

    const socket = io(connectUrl);

    socket.on('connect', () => console.log('connected to -> ws://localhost:3000'));
    socket.on("disconnect", (reason, details) => console.log('disconnected from -> ws://localhost:3000', reason, details));

    const message = ref('');
    const joinRoomName = ref('');
    const joinedRooms = ref([]);

    const messages = ref({});

    socket.on('message', ({ text, roomName, name }) => messages.value[roomName].push({ text, name }));

    const sendMessage = (roomName) => {
      socket.emit('message', { text: message.value, roomName }, (status) => console.log('message acknowledged ->', status));

      messages.value[roomName].push({ name: socket.id, text: message.value });
      message.value = '';
    };

    const joinRoom = () => {
      socket.emit('join-room', { roomName: joinRoomName.value }, ({ status, joinedRooms: socketJoinedRooms }) => {
        console.log('join-room acknowledged ->', status);

        messages.value[joinRoomName.value] = [];

        joinedRooms.value = socketJoinedRooms;
      });
    }

    const leaveRoom = (roomName) => {
      socket.emit('leave-room', { roomName: roomName }, ({ status, joinedRooms: socketJoinedRooms }) => {
        console.log('leave-room acknowledged ->', status);

        delete messages.value[roomName];
        joinedRooms.value = socketJoinedRooms;
      });
    }

    return {
      message,

      joinRoomName,
      joinedRooms,
      messages,

      sendMessage,
      joinRoom,
      leaveRoom
    }
  }
})
</script>

<style lang="scss">
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}

.rooms {
  display: flex;
  flex-wrap: wrap;
  row-gap: 16px;
  column-gap: 16px;
}

.room-container {
  width: 300px;
  height: 500px;
  display: flex;
  flex-direction: column;
  padding: 16px;
  border-radius: 4px;

  overflow: hidden;
  border: 1px solid grey;
}

.room-messages {
  flex-grow: 1;
}
</style>
