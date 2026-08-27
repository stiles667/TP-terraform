const counterButton = document.querySelector('#counter-button');
const counterValue = document.querySelector('#counter-value');
let count = 0;

counterButton.addEventListener('click', () => {
  count += 1;
  counterValue.textContent = count;
});
