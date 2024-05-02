const connectUrl = new URL(window.location).searchParams.get('c');

    const socket = io(connectUrl, { withCredentials: true });

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