import React, { useState, useEffect, useCallback } from "react";
import {
  Card,
  Button,
  Row,
  Col,
  Alert,
  Spinner,
  Form,
  InputGroup,
  Pagination,
} from "react-bootstrap";
import { Link } from "react-router-dom";
import { userAPI } from "../services/api";

const UserList = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [searchTerm, setSearchTerm] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalUsers, setTotalUsers] = useState(0);
  const usersPerPage = 6;

  const fetchUsers = useCallback(async () => {
    try {
      setLoading(true);
      const response = await userAPI.getUsers(currentPage, usersPerPage);
      setUsers(response.data.users);
      setTotalPages(response.data.totalPages);
      setTotalUsers(response.data.totalUsers);
      setError("");
    } catch (err) {
      setError("Failed to fetch users");
      console.error("Error fetching users:", err);
    } finally {
      setLoading(false);
    }
  }, [currentPage, usersPerPage]);

  const handleSearch = useCallback(async () => {
    if (!searchTerm.trim()) {
      fetchUsers();
      return;
    }

    try {
      setLoading(true);
      const response = await userAPI.searchUsers(searchTerm);
      setUsers(response.data);
      setTotalPages(1);
      setCurrentPage(1);
      setError("");
    } catch (err) {
      setError("Search failed");
      console.error("Error searching users:", err);
    } finally {
      setLoading(false);
    }
  }, [searchTerm, fetchUsers]);

  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);

  useEffect(() => {
    if (searchTerm) {
      handleSearch();
    } else {
      fetchUsers();
    }
  }, [searchTerm, handleSearch, fetchUsers]);

  const handleDelete = async (id, userName) => {
    if (window.confirm(`Are you sure you want to delete ${userName}?`)) {
      try {
        await userAPI.deleteUser(id);
        setSuccess("User deleted successfully!");
        fetchUsers();
        setTimeout(() => setSuccess(""), 3000);
      } catch (err) {
        setError("Failed to delete user");
        console.error("Error deleting user:", err);
      }
    }
  };

  const handlePageChange = (pageNumber) => {
    setCurrentPage(pageNumber);
  };

  const renderPagination = () => {
    if (totalPages <= 1 || searchTerm) return null;

    let items = [];
    const maxVisiblePages = 5;
    let startPage = Math.max(1, currentPage - Math.floor(maxVisiblePages / 2));
    let endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);

    if (endPage - startPage < maxVisiblePages - 1) {
      startPage = Math.max(1, endPage - maxVisiblePages + 1);
    }

    // Previous button
    items.push(
      <Pagination.Prev
        key="prev"
        disabled={currentPage === 1}
        onClick={() => handlePageChange(currentPage - 1)}
      />
    );

    // Page numbers
    for (let page = startPage; page <= endPage; page++) {
      items.push(
        <Pagination.Item
          key={page}
          active={page === currentPage}
          onClick={() => handlePageChange(page)}
        >
          {page}
        </Pagination.Item>
      );
    }

    // Next button
    items.push(
      <Pagination.Next
        key="next"
        disabled={currentPage === totalPages}
        onClick={() => handlePageChange(currentPage + 1)}
      />
    );

    return (
      <div className="pagination-container">
        <Pagination>{items}</Pagination>
      </div>
    );
  };

  if (loading) {
    return (
      <div className="loading">
        <Spinner animation="border" role="status">
          <span className="visually-hidden">Loading...</span>
        </Spinner>
        <p>Loading users...</p>
      </div>
    );
  }

  return (
    <div>
      <div className="d-flex justify-content-between align-items-center mb-4">
        <h2>Users Management</h2>
        <Button as={Link} to="/add" variant="primary">
          Add New User
        </Button>
      </div>

      {error && <Alert variant="danger">{error}</Alert>}
      {success && <Alert variant="success">{success}</Alert>}

      <div className="search-box">
        <InputGroup>
          <Form.Control
            type="text"
            placeholder="Search users by name or email..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          <Button
            variant="outline-secondary"
            onClick={() => setSearchTerm("")}
            disabled={!searchTerm}
          >
            Clear
          </Button>
        </InputGroup>
      </div>

      <div className="mb-3">
        <small className="text-muted">
          {searchTerm
            ? `Found ${users.length} user(s) matching "${searchTerm}"`
            : `Showing ${users.length} of ${totalUsers} users`}
        </small>
      </div>

      {users.length === 0 ? (
        <Alert variant="info">
          {searchTerm
            ? "No users found matching your search."
            : "No users found. Add your first user!"}
        </Alert>
      ) : (
        <Row>
          {users.map((user) => (
            <Col md={6} lg={4} key={user._id} className="mb-3">
              <Card className="h-100">
                <Card.Body>
                  <Card.Title>{user.name}</Card.Title>
                  <Card.Text>
                    <strong>Email:</strong> {user.email}
                    <br />
                    {user.age && (
                      <>
                        <strong>Age:</strong> {user.age}
                        <br />
                      </>
                    )}
                    {user.city && (
                      <>
                        <strong>City:</strong> {user.city}
                        <br />
                      </>
                    )}
                    {user.phone && (
                      <>
                        <strong>Phone:</strong> {user.phone}
                        <br />
                      </>
                    )}
                    <small className="text-muted">
                      Created: {new Date(user.createdAt).toLocaleDateString()}
                    </small>
                  </Card.Text>
                </Card.Body>
                <Card.Footer className="bg-transparent">
                  <div className="d-flex justify-content-between">
                    <Button
                      as={Link}
                      to={`/edit/${user._id}`}
                      variant="outline-primary"
                      size="sm"
                    >
                      Edit
                    </Button>
                    <Button
                      variant="outline-danger"
                      size="sm"
                      onClick={() => handleDelete(user._id, user.name)}
                    >
                      Delete
                    </Button>
                  </div>
                </Card.Footer>
              </Card>
            </Col>
          ))}
        </Row>
      )}

      {renderPagination()}
    </div>
  );
};

export default UserList;
