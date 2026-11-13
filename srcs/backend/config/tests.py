from django.test import SimpleTestCase
from django.urls import reverse


class HelloWorldTests(SimpleTestCase):
    def test_hello_world(self):
        response = self.client.get(reverse("hello-world"))

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response["Content-Type"], "application/json")
        self.assertEqual(
            response.json(), {"message": "Hello world!", "service": "backend"}
        )

    def test_head(self):
        response = self.client.head(reverse("hello-world"))

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, b"")

    def test_post_is_not_allowed(self):
        response = self.client.post(reverse("hello-world"))

        self.assertEqual(response.status_code, 405)
        self.assertEqual(response["Allow"], "GET, HEAD")

    def test_missing_route(self):
        self.assertEqual(self.client.get("/api/missing/").status_code, 404)

    def test_unknown_host_is_rejected(self):
        response = self.client.get(reverse("hello-world"), HTTP_HOST="invalid.example")

        self.assertEqual(response.status_code, 400)
