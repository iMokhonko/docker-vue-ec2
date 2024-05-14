<template>
	<div class="message">
		<div 
      class="avatar"
      :style="{ backgroundColor: `${avatarBgColor}` }"
    >
      {{ chatAvatarChars }}
    </div>
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

import generageColorBasedOnChars from '@/helpers/generate-color-based-on-chars';

export default defineComponent({
  emits: ['hook:mounted'],
  
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

  mounted() {
    this.$emit('hook:mounted')
  },

	computed: {
    avatarBgColor() {
      return generageColorBasedOnChars(this.name);
    },

    chatAvatarChars() {
			const words = this.name.split('.');

			return words.map(word => word[0].toUpperCase()).join('');
		},

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
</style>