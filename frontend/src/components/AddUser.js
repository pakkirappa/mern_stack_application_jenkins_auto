import React, { useState } from "react";
import {
  Form,
  Button,
  Alert,
  Card,
  Container,
  Row,
  Col,
} from "react-bootstrap";
import { useNavigate, Link } from "react-router-dom";
import { userAPI } from "../services/api";

const AddUser = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    age: "",
    city: "",
    phone: "",
  });

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

      await userAPI.createUser(userData);
      navigate("/", { state: { message: "User created successfully!" } });
    } catch (err) {
      setError(err.response?.data?.error || "Failed to create user");
      console.error("Error creating user:", err);
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setFormData({
      name: "",
      email: "",
      age: "",
      city: "",
      phone: "",
    });
    setError("");
  };

  return (
    <Container>
      <Row className="justify-content-center">
        <Col md={8} lg={6}>
          <Card>
            <Card.Header className="bg-primary text-white">
              <h3 className="mb-0">Add New User</h3>
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
                  <Button type="submit" variant="primary" disabled={loading}>
                    {loading ? "Creating..." : "Create User"}
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

export default AddUser;
