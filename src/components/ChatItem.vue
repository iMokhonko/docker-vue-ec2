<template>
  <div 
		class="chat-item"
		:class="{ 'active': isActive }"
	>
		<div 
			class="chat-item__avatar"
			:style="{ backgroundColor: `${avatarBgColor}` }"
		>
			{{  chatAvatarChars  }}
		</div>

		<div class="chat-item__content">
			<div class="chat-item__name">
				{{ name }} <span v-if="isOnline" class="status">online</span>
			</div>

			<div v-if="lastMessageText" class="chat-item__message-text">
				{{ isOwnMessage ? 'You: ' : '' }}{{ lastMessageText }}
			</div>
		</div>

		<div class="chat-item__info">
			<div v-if="lastMessageTime" class="chat-item__info-time">{{ time }}</div>
			<div v-if="unreadMessagesCount" class="chat-item__info-new-messages-count">{{ unreadMessagesCount }}</div>
		</div>
	</div>
</template>

<script>
import { defineComponent } from 'vue';

import generageColorBasedOnChars from '@/helpers/generate-color-based-on-chars';

export default defineComponent({
	props: {
		isActive: {
			type: Boolean,
			default: false
		},

		name: {
			type: String,
			required: true
		},

		unreadMessagesCount: {
			type: Number,
			default: 0
		},

		isOwnMessage: {
			type: Boolean,
			default: false
		},

		lastMessageText: {
			type: String,
			default: ''
		},

		lastMessageTime: {
			type: Number,
			default: 0
		},

    isOnline: {
      type: Boolean,
      default: false
    }
	},

	computed: {
		time() {
			const date = new Date(this.lastMessageTime);

			const hours = date.getHours();
			const minutes = "0" + date.getMinutes();

			return hours + ':' + minutes.substr(-2);
		},

		chatAvatarChars() {
			const words = this.name.split('.');

			return words.map(word => word[0].toUpperCase()).join('');
		},

		avatarBgColor() {
      return generageColorBasedOnChars(this.name);
    },
		
	}
})
</script>

<style lang="scss" scoped>
.chat-item {
	padding: 16px;
	display: flex;
	column-gap: 8px;
	width: 100%;
	max-width: 100%;
	cursor: pointer;
	border-top-right-radius: 4px;
	border-bottom-right-radius: 4px;

	&.active {
		background: rgba(0, 95, 177, 0.08);
	}

	&__avatar {
		width: 48px;
		height: 48px;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
		font-weight: bold;
		font-size: 12px;
		flex-shrink: 0;
		color: #fff;
	}

	&__content {
		display: flex;
		flex-direction: column;
		row-gap: 4px;
	}

	&__name {
		font-weight: bold;
	}

	&__message-text {
		font-size: 12px;

		text-overflow: ellipsis;
		white-space: nowrap;
		overflow: hidden;
		max-width: 220px;
	}

	&__info {
		display: flex;
		flex-direction: column;
		margin-left: auto;
		position: relative;
		justify-content: space-between;
		row-gap: 8px;
		flex-shrink: 0;

		&-time {
			font-size: 10px;
			color: grey;
			margin-left: auto;
		}

		&-new-messages-count {
			font-size: 12px;
			background: lightblue;
			padding: 4px 8px;
			border-radius: 100px;
			font-weight: bold;
			display: flex;
			justify-content: center;
			align-items: center;
			color: #000;
		}
	}

  .status {
    font-size: 12px;
    color: green;
    font-weight: normal;
  }
}
</style>