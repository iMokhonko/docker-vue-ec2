<template>
	<div class="message">
		<div class="avatar">IM</div>
		<div class="message__content">
			<div class="name">{{ name }} <span class="time">{{  time  }}</span></div>
			<div class="message-text">
				{{ messageText }}
			</div>
		</div>
	</div>
</template>

<script>
import { defineComponent } from 'vue';

export default defineComponent({
	props: {
		name: {
			type: String,
			required: true,
		},

		messageText: {
			type: String,
			required: true,
		},

		messageTime: {
			type: Number,
			default: 0
		}
	},

	computed: {
		time() {
			const date = new Date(this.messageTime);

			const hours = date.getHours();
			const minutes = "0" + date.getMinutes();

			return hours + ':' + minutes.substr(-2);
		}
	}
});
</script>

<style lang="scss" scoped>

.message {
  display: flex;
  column-gap: 8px;
  max-width: 100%;
  overflow: hidden;
  flex-shrink: 0;

  .avatar {
    flex-shrink: 0;
  }

  .name {
    font-size: 14px;
  }

  .message-text {
    font-size: 14px;
  }

  &__content {
    display: flex;
    flex-direction: column;
    row-gap: 4px;
  }
}

.time {
  font-size: 10px;
  color: grey;
  font-weight: normal;
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
</style>