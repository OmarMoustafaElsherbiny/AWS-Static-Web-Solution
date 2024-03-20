const counter = document.querySelector(".counter-number");
const apiUrl = "Your-LambdaFunction-URL";
async function updateCounter() {
  let response = await fetch(apiUrl);
  let data = await response.json();
  counter.innerHTML = ` This page has ${data} Views!`;
}

updateCounter();
