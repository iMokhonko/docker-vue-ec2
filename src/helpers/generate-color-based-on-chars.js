/**
 * Hashes a string to an integer value
 * @param {string} str - The string to hash.
 * @returns {number} - The hashed integer value.
 */
function hashString(str) {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    hash = str.charCodeAt(i) + ((hash << 5) - hash);
    hash = hash & hash; // Convert to 32bit integer
  }
  return hash >>> 0; // Make sure it's unsigned
}

/**
 * Generates a hexadecimal color code based on a hash value.
 * @param {number} hash - The hash value.
 * @returns {string} - The hexadecimal color code.
 */
function hashToColor(hash) {
  const random = (seed) => {
    // Basic random function using the seed
    var x = Math.sin(seed) * 10000;
    return x - Math.floor(x);
  };

  const r = Math.floor(random(hash) * 256);
  const g = Math.floor(random(hash + 1) * 256);
  const b = Math.floor(random(hash + 2) * 256);

  return `rgb(${r}, ${g}, ${b})`;
}

/**
 * Generates a random color based on a string.
 * @param {string} str - The input string.
 * @returns {string} - CSS-friendly color code (in this case, RGB).
 */
function stringToRandomColor(str) {
  const hash = hashString(str);
  return hashToColor(hash);
}

export default stringToRandomColor;