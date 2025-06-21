fetch("https://joi-prototype.onrender.com/chat", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ message: "hi" })
  })
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error(error));
  