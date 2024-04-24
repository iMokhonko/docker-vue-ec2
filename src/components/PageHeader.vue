<template>
  <header class="header">
    <h1>Messenger</h1>

    <button>Profile</button>
  </header>
</template>

<style lang="scss" scoped>
.header {
  display: flex;
  padding: 8px 16px;
  align-items: center;
  column-gap: 16px;
  background-color: rgba(0, 0, 0, 1);

  justify-content: space-between;
  width: 100%;

  h1 {
    margin: 0;
    padding: 0;
    color: #fff;
  }
}
</style>