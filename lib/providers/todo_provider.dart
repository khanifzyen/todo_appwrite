import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import '../models/todo.dart';
import '../constants.dart';

class TodoProvider with ChangeNotifier {
  final Client _client = Client();
  final Databases _databases;

  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  TodoProvider() : _databases = Databases(Client()) {
    _client.setEndpoint(endpoint).setProject(projectId);
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
      );
      _todos = response.documents.map((doc) => Todo.fromMap(doc.data)).toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> addTodo(String title) async {
    try {
      final response = await _databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: 'unique()',
        data: {
          'title': title,
          'isCompleted': false,
        },
      );
      _todos.add(Todo.fromMap(response.data));
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> toggleTodoStatus(Todo todo) async {
    try {
      final updatedTodo = Todo(
        id: todo.id,
        title: todo.title,
        isCompleted: !todo.isCompleted,
      );
      await _databases.updateDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: todo.id,
        data: updatedTodo.toMap(),
      );
      final index = _todos.indexWhere((t) => t.id == todo.id);
      _todos[index] = updatedTodo;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> removeTodo(String id) async {
    try {
      await _databases.deleteDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: id,
      );
      _todos.removeWhere((todo) => todo.id == id);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
