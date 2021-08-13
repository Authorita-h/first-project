import React, {useState} from "react"
import './App.css';

function App() {
  const [value,setvalue] =  useState(undefined)
  const request =() =>{ fetch("http://api:5000/").then(response => response.text()).then(res => setvalue(res))};
  
  return (
    <div className="App">
      <button onClick={request} >click</button>
      <div>{value}</div>
    </div>
  );
}

export default App;
