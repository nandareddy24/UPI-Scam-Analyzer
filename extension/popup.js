document.getElementById('scanBtn').addEventListener('click', () => {
  const type = document.getElementById('scanType').value;
  const data = document.getElementById('targetInput').value.trim();
  const resDiv = document.getElementById('result');

  if (!data) {
    resDiv.style.display = 'block';
    resDiv.style.background = '#fef3c7';
    resDiv.innerText = 'Please enter a target input.';
    return;
  }

  resDiv.style.display = 'block';
  resDiv.style.background = '#f1f5f9';
  resDiv.innerText = 'Analyzing threat parameters...';

  fetch('http://127.0.0.1:3000/api/v1/analyze', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ type: type, data: data })
  })
  .then(res => res.json())
  .then(res => {
    const isSafe = res.result === 'Safe';
    const isWarn = res.result === 'Warning';
    resDiv.style.background = isSafe ? '#dcfce7' : (isWarn ? '#fef3c7' : '#fee2e2');
    resDiv.style.color = isSafe ? '#14532d' : (isWarn ? '#92400e' : '#991b1b');
    resDiv.innerHTML = `
      <b>Result: ${res.result}</b> (Score: ${res.score})<br>
      Confidence: ${res.confidence}%<br>
      <i>${res.reason}</i><br><br>
      💡 ${res.advice}
    `;
  })
  .catch(() => {
    resDiv.style.background = '#fee2e2';
    resDiv.innerText = 'Failed to connect to Scam Shield server at 127.0.0.1:3000.';
  });
});
