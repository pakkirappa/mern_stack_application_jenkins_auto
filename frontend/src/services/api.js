import axios from "axios";

const API_BASE_URL =
  process.env.REACT_APP_API_URL || "http://localhost:5000/api";

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

// User API endpoints
export const userAPI = {
  // Get all users with pagination
  getUsers: (page = 1, limit = 10) => {
    return api.get(`/users?page=${page}&limit=${limit}`);
  },

  // Get a single user by ID
  getUserById: (id) => {
    return api.get(`/users/${id}`);
  },

  // Create a new user
  createUser: (userData) => {
    return api.post("/users", userData);
  },

  // Update an existing user
  updateUser: (id, userData) => {
    return api.put(`/users/${id}`, userData);
  },

  // Delete a user
  deleteUser: (id) => {
    return api.delete(`/users/${id}`);
  },

  // Search users
  searchUsers: (query) => {
    return api.get(`/users/search/${encodeURIComponent(query)}`);
  },
};

// Add request interceptor for error handling
api.interceptors.request.use(
  (config) => {
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Add response interceptor for error handling
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    console.error("API Error:", error.response?.data || error.message);
    return Promise.reject(error);
  }
);

export default api;
