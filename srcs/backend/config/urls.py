from django.http import JsonResponse
from django.urls import path
from django.views.decorators.http import require_safe


@require_safe
def hello_world(request):
    return JsonResponse({"message": "Hello world!", "service": "backend"})


urlpatterns = [
    path("api/", hello_world, name="hello-world"),
]
