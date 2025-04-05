import React, { useState } from "react";

function Search() {
  const [query, setQuery] = useState("");
  const [results, setResults] = useState([]);

  const handleSearch = async () => {
    try {
      const res = await fetch(`http://localhost:8000/search?query=${encodeURIComponent(query)}`);
      const data = await res.json();
      setResults(data.results || []);
    } catch (err) {
      console.error("Search failed", err);
      setResults([]);
    }
  };

  const clearResults = () => {
    setResults([]);
    setQuery("");
  };

  return (
    <div style={{ padding: "1rem", backgroundColor: "#f9f9f9", border: "1px solid #ccc", borderRadius: "6px", marginTop: "2rem" }}>
      <h2>Search Embedded Content</h2>
      <input
        type="text"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Type your question or topic..."
        style={{ width: "300px", padding: "6px", marginRight: "1rem" }}
      />
      <button onClick={handleSearch} style={{ marginRight: "0.5rem" }}>Search</button>
      <button onClick={clearResults}>Clear</button>

      {results.length > 0 && (
        <div style={{ marginTop: "1rem", maxHeight: "300px", overflowY: "auto" }}>
          {results.map((r, i) => (
            <div key={i} style={{
              marginBottom: "0.75rem",
              padding: "0.75rem",
              backgroundColor: "#fff",
              border: "1px solid #ddd",
              borderRadius: "4px",
              fontSize: "0.95rem",
              lineHeight: "1.5"
            }}>
              <div>{r.text}</div>
              <div style={{ fontSize: "0.8rem", color: "#666" }}>
                🔢 Score: {r.score}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default Search;
