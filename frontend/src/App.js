import React, { useState } from 'react';

function App() {
  const [file, setFile] = useState(null);
  const [summary, setSummary] = useState('');
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);

  const handleUpload = async () => {
    const formData = new FormData();
    formData.append("file", file);
    const res = await fetch("http://localhost:8000/upload", {
      method: "POST",
      body: formData
    });
    const data = await res.json();
    setSummary(data.summary);
  };

  const handleSearch = async () => {
    const formData = new FormData();
    formData.append("query", query);
    const res = await fetch("http://localhost:8000/search", {
      method: "POST",
      body: formData
    });
    const data = await res.json();
    setResults(data.results);
  };

  return (
    <div style={{ padding: '2rem' }}>
      <h1>AI Summary Assistant</h1>
      <input type="file" onChange={e => setFile(e.target.files[0])} />
      <button onClick={handleUpload}>Upload & Summarize</button>
      <p><strong>Summary:</strong> {summary}</p>

      <hr />
      <input type="text" value={query} onChange={e => setQuery(e.target.value)} placeholder="Search summaries..." />
      <button onClick={handleSearch}>Search</button>
      <ul>
        {results.map((r, i) => <li key={i}>{r}</li>)}
      </ul>
    </div>
  );
}

export default App;
