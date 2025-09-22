import React, { useState, useEffect } from "react";
import {
  Form,
  Button,
  Alert,
  Card,
  Container,
  Row,
  Col,
  Spinner,
} from "react-bootstrap";
import { useNavigate, useParams, Link } from "react-router-dom";
import { userAPI } from "../services/api";

const EditUser = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const [loading, setLoading] = useState(false);
  const [fetchingUser, setFetchingUser] = useState(true);
  const [error, setError] = useState("");
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    age: "",
    city: "",
    phone: "",
  });

  useEffect(() => {
    fetchUser();
  }, [id]);

  const fetchUser = async () => {
    try {
      setFetchingUser(true);
      const response = await userAPI.getUserById(id);
      const user = response.data;
      setFormData({
        name: user.name || "",
        email: user.email || "",
        age: user.age ? user.age.toString() : "",
        city: user.city || "",
        phone: user.phone || "",
      });
      setError("");
    } catch (err) {
      setError("Failed to fetch user details");
      console.error("Error fetching user:", err);
    } finally {
      setFetchingUser(false);
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prevState) => ({
      ...prevState,
      [name]: value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");

    try {
      // Convert age to number if provided
      const userData = {
        ...formData,
        age: formData.age ? parseInt(formData.age) : undefined,
      };

      await userAPI.updateUser(id, userData);
      navigate("/", { state: { message: "User updated successfully!" } });
    } catch (err) {
      setError(err.response?.data?.error || "Failed to update user");
      console.error("Error updating user:", err);
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    fetchUser(); // Reset to original values
    setError("");
  };

  if (fetchingUser) {
    return (
      <Container>
        <Row className="justify-content-center">
          <Col md={8} lg={6}>
            <div className="text-center p-4">
              <Spinner animation="border" role="status">
                <span className="visually-hidden">Loading...</span>
              </Spinner>
              <p className="mt-2">Loading user details...</p>
            </div>
          </Col>
        </Row>
      </Container>
    );
  }

  return (
    <Container>
      <Row className="justify-content-center">
        <Col md={8} lg={6}>
          <Card>
            <Card.Header className="bg-warning text-dark">
              <h3 className="mb-0">Edit User</h3>
            </Card.Header>
            <Card.Body>
              {error && <Alert variant="danger">{error}</Alert>}

              <Form onSubmit={handleSubmit}>
                <Form.Group className="mb-3">
                  <Form.Label>Name *</Form.Label>
                  <Form.Control
                    type="text"
                    name="name"
                    value={formData.name}
                    onChange={handleChange}
                    required
                    placeholder="Enter full name"
                    minLength="2"
                    maxLength="50"
                  />
                  <Form.Text className="text-muted">
                    Name should be between 2-50 characters
                  </Form.Text>
                </Form.Group>

                <Form.Group className="mb-3">
                  <Form.Label>Email *</Form.Label>
                  <Form.Control
                    type="email"
                    name="email"
                    value={formData.email}
                    onChange={handleChange}
                    required
                    placeholder="Enter email address"
                  />
                  <Form.Text className="text-muted">
                    Please enter a valid email address
                  </Form.Text>
                </Form.Group>

                <Form.Group className="mb-3">
                  <Form.Label>Age</Form.Label>
                  <Form.Control
                    type="number"
                    name="age"
                    value={formData.age}
                    onChange={handleChange}
                    min="1"
                    max="150"
                    placeholder="Enter age"
                  />
                  <Form.Text className="text-muted">
                    Age should be between 1-150 years (optional)
                  </Form.Text>
                </Form.Group>

                <Form.Group className="mb-3">
                  <Form.Label>City</Form.Label>
                  <Form.Control
                    type="text"
                    name="city"
                    value={formData.city}
                    onChange={handleChange}
                    placeholder="Enter city name"
                    maxLength="100"
                  />
                  <Form.Text className="text-muted">
                    City name (optional)
                  </Form.Text>
                </Form.Group>

                <Form.Group className="mb-4">
                  <Form.Label>Phone</Form.Label>
                  <Form.Control
                    type="text"
                    name="phone"
                    value={formData.phone}
                    onChange={handleChange}
                    placeholder="Enter phone number"
                    pattern="[0-9\-\+\s\(\)]+"
                  />
                  <Form.Text className="text-muted">
                    Phone number with country code (optional)
                  </Form.Text>
                </Form.Group>

                <div className="d-grid gap-2 d-md-flex justify-content-md-end">
                  <Button
                    variant="secondary"
                    onClick={handleReset}
                    disabled={loading}
                  >
                    Reset
                  </Button>
                  <Button
                    as={Link}
                    to="/"
                    variant="outline-secondary"
                    disabled={loading}
                  >
                    Cancel
                  </Button>
                  <Button type="submit" variant="warning" disabled={loading}>
                    {loading ? "Updating..." : "Update User"}
                  </Button>
                </div>
              </Form>
            </Card.Body>
          </Card>
        </Col>
      </Row>
    </Container>
  );
};

export default EditUser;
