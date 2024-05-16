<template>
	<div class="search-result">
		<div 
			class="search-result__avatar"
			:style="{ backgroundColor: `${avatarBgColor}` }"
		>
			{{  chatAvatarChars  }}
		</div>

		<div class="search-result__name">
			{{ name }}
			</div>
	</div>
</template>

<script>
import generageColorBasedOnChars from '@/helpers/generate-color-based-on-chars';

export default {
	props: {
		name: {
			type: String,
			default: ''
		}
	},

	computed: {
		chatAvatarChars() {
			const words = this.name.split('.');

			return words.map(word => word[0].toUpperCase()).join('');
		},

		avatarBgColor() {
      return generageColorBasedOnChars(this.name);
    },
	}
}
</script>

<style lang="scss">
.search-result {
	display: flex;
	column-gap: 8px;
	width: 100%;
	max-width: 100%;
	cursor: pointer;
	padding: 8px 16px;
	align-items: center;

	&:hover {
		background: rgba(0, 95, 177, 0.08);
	}

	&__avatar {
		width: 32px;
		height: 32px;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
		font-weight: bold;
		font-size: 12px;
		flex-shrink: 0;
		color: #fff;
	}

	&__name {
		font-weight: bold;
	}
}
</style>