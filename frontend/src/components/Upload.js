import React, { useState } from "react";

function Upload() {
  const [file, setFile] = useState(null);
  const [message, setMessage] = useState("");

  const handleChange = (e) => {
    setFile(e.target.files[0]);
  };

  const handleUpload = async () => {
    if (!file) {
      alert("Please choose a file first!");
      return;
    }

    const formData = new FormData();
    formData.append("file", file);

    try {
      const response = await fetch("http://localhost:8000/upload", {
        method: "POST",
        body: formData,
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      setMessage(`✅ Upload successful: ${data.message}`);
    } catch (err) {
      console.error("Upload failed", err);
      setMessage("❌ Upload failed");
    }
  };

  return (
    <div style={{ padding: "1rem" }}>
      <h2>Upload PDF</h2>
      <input type="file" onChange={handleChange} />
      <button onClick={handleUpload}>Upload</button>
      <p>{message}</p>
    </div>
  );
}

export default Upload;
