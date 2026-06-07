import { useState, useEffect } from 'react'
import axios from 'axios'
import './App.css'

const API_URL = 'http://localhost:8080/api/todos'

function App() {
  const [todos, setTodos] = useState([]);
  const [newTodo, setNewTodo] = useState('');
  const [banner, setBanner] = useState({
    show: false,
    message: '',
    type: 'error' | 'success',
  });

  const addTodo = async e => {
    e.preventDefault();
    if (!newTodo.trim()) {
      setBanner({
        show: true,
        message: 'Todo title cannot be empty',
        type: 'error',
      });
      return;
    }
    setBanner(null);
    try {
      const response = await axios.post(API_URL, {
        title: newTodo,
        completed: false,
      });
      setTodos([...todos, response.data.data]);
      setNewTodo('');
      setBanner({
        show: true,
        message: 'Todo added successfully!',
        type: 'success',
      });
    } catch (error) {
      setBanner({
        show: true,
        message: 'Failed to add todo. Please try again.',
        type: 'error',
      });
      console.error('Error adding todo:', error);
    }
  };

  const toggleTodo = async todo => {
    try {
      const response = await axios.put(`${API_URL}/${todo.id}`, {
        ...todo,
        completed: !todo.completed,
      });
      setTodos(todos.map(t => (t.id === todo.id ? response.data.data : t)));
    } catch (error) {
      console.error('Error toggling todo:', error);
    }
  };

  const deleteTodo = async id => {
    try {
      await axios.delete(`${API_URL}/${id}`);
      setTodos(todos.filter(t => t.id !== id));
    } catch (error) {
      console.error('Error deleting todo:', error);
    }
  };

  useEffect(() => {
    const fetchTodos = async () => {
      try {
        const response = await axios.get(API_URL);
        setTodos(response.data.data);
      } catch (error) {
        console.error('Error fetching todos:', error);
      }
    };
    fetchTodos();
  }, []);

  useEffect(() => {
    if (banner && banner.show) {
      const timer = setTimeout(() => {
        setBanner(null);
      }, 3000);
      return () => clearTimeout(timer);
    }
  }, [banner]);
  
  return (
    <div className="todo-container">
      <h1>Todo List</h1>
      {banner && <p className={`banner ${banner.type}`}>{banner.message}</p>}
      <form onSubmit={addTodo} className="todo-form">
        <input type="text" value={newTodo} onChange={e => setNewTodo(e.target.value)} placeholder="Add a new task..." />
        <button type="submit">Add</button>
      </form>

      <ul className="todo-list">
        {todos.map(todo => (
          <li key={todo.id} className={todo.completed ? 'completed' : ''}>
            <span onClick={() => toggleTodo(todo)}>{todo.title}</span>
            <button onClick={() => deleteTodo(todo.id)} className="delete-btn">
              Delete
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App
