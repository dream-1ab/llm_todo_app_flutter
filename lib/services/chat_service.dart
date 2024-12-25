import 'dart:async';
import 'dart:convert';

import 'package:hello_flutter_llm/models/app_theme.dart';
import 'package:hello_flutter_llm/models/chat_actions.dart';
import 'package:hello_flutter_llm/providers/app_state.dart';
import 'package:openai_dart/openai_dart.dart';

enum ChatMessageRole {
  user,
  assistant,
  system,
}

enum ActionType {
  add_task,
  complete_task,
  delete_task,
  undo_previous_operation,
  change_app_color_theme,
  nothing,
}

class ChatService {
  late final OpenAIClient _client;
  final List<ChatMessage> _messageHistory = [];
  static const int _maxHistoryLength = 10;
  final AppState _appState;
  
  ChatService(this._appState) {
    _client = OpenAIClient(
      apiKey: 'sk-qKwnY5gMCujJ49VeIXUJjA9Ogi0z6LO0KfmzZfBarLI366yI',
      baseUrl: 'https://api.moonshot.cn/v1',
    );
  }

  List<ChatMessage> get messageHistory => List.unmodifiable(_messageHistory);

  void addMessage(String content, bool isUser) {
    _messageHistory.add(ChatMessage(
      content: content,
      role: isUser ? ChatMessageRole.user : ChatMessageRole.assistant,
    ));
    
    // Keep only the most recent messages
    if (_messageHistory.length > _maxHistoryLength) {
      _messageHistory.removeAt(0);
    }
  }

  Future<List<ActionType>> decideAction(String message) async {
    try {
      // Prepare messages for action classification
      final messages = [
        const ChatCompletionMessage.system(
          content: '''Classify the user message into array of these actions:
          - add_task: When user wants to add/schedule a new task
          - complete_task: When user wants to mark a task as done
          - delete_task: When user wants to delete a task
          - undo_previous_operation: When user wants to undo last action
          - change_app_color_theme: When user wants to change app theme/color
          - other: For general questions or unrelated requests
          
          split user message into multiple actions if possible.

          example:
          user: "I want to meet with my friend tomorrow at 10am and then go to the gym at 12pm so cancel watching the movie"
          assistant: ["add_task", "add_task", "delete_task"]
          Respond with ONLY the action types as an array, nothing else.''',
        ),
        ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string(message)
        ),
      ];

      final response = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId('moonshot-v1-8k'),
          messages: messages,
          temperature: 0,
          tools: [
            ChatCompletionTool(type: ChatCompletionToolType.function, function: FunctionObject(
              name: "user_action",
              description: "Deside what the user wants to do",
              parameters: {
                "type": "object",
                "required": ["actions"],
                "properties": {
                  "actions": {
                    "type": "array",
                    "items": {
                      "type": "string",
                      "enum": ActionType.values.map((e) => e.name).toList(),
                    },
                    "description": "The actions the user wants to do",
                  },
                },
              },
            ))
          ]
        ),
      );
      final result = response.choices.first;
      final textOfActions = result.message.toolCalls?.first.function.arguments ?? "";
      final actions = (jsonDecode(textOfActions)["actions"] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];
      // print(textOfActions);
      return actions.map((e) => ActionType.values.firstWhere((element) => element.name == e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<(List<LLMDecision>?, String?)> extractActions(String message, List<ActionType> actions) async {
    final messages = [
      ChatCompletionMessage.system(
        content: '''
You are expert analyzer.
Your task is: based on user message, extract the specified actions and return them as a JSON object array.
actions you have to extract: ${actions.map((e) => e.name).join(', ')}
don't require user to provide exact values, just extract the values based on the user message.
if the context is not sufficient to extract the action parameters, desribe what you need to know to extract the action parameters as error message.

expected output json schema:
{
  "type": "object",
  "required": ["code", "error_message", "actions"],
  "properties": {
    "code": {
      "type": "string",
      "description": "0 if context is sufficient, 1 if insufficient"
    },
    "error_message": {
      "type": "string",
      "description": "Error message in user's language if context insufficient"
    },
    "actions": {
      "type": "array",
      "items": {
        "type": "object",
        "oneOf": [
          {
            "type": "object",
            "required": ["add_new_task"],
            "properties": {
              "add_new_task": {
                "type": "object",
                "required": ["title", "description", "due_date"],
                "properties": {
                  "title": {
                    "type": "string",
                    "description": "The title of the task"
                  },
                  "description": {
                    "type": "string", 
                    "description": "The description of the task"
                  },
                  "due_date": {
                    "type": "string",
                    "format": "date-time",
                    "description": "The due date of the task"
                  }
                }
              }
            }
          },
          {
            "type": "object", 
            "required": ["complete_task"],
            "properties": {
              "complete_task": {
                "type": "object",
                "required": ["task_id"],
                "properties": {
                  "task_id": {
                    "type": "string",
                    "description": "The ID of the task to mark as complete"
                  }
                }
              }
            }
          },
          {
            "type": "object",
            "required": ["delete_task"],
            "properties": {
              "delete_task": {
                "type": "object", 
                "required": ["task_id"],
                "properties": {
                  "task_id": {
                    "type": "string",
                    "description": "The ID of the task to delete"
                  }
                }
              }
            }
          },
          {
            "type": "object",
            "required": ["undo_previous_operation"],
            "properties": {
              "undo_previous_operation": {
                "type": "object",
                "required": ["undo_count"],
                "properties": {
                  "undo_count": {
                    "type": "integer",
                    "description": "The number of operations to undo"
                  }
                }
              }
            }
          },
          {
            "type": "object",
            "required": ["change_app_color_theme"],
            "properties": {
              "change_app_color_theme": {
                "type": "object",
                "required": ["theme"],
                "properties": {
                  "theme": {
                    "type": "string",
                    "description": "The new color theme"
                  }
                }
              }
            }
          }
        ]
      }
    }
  }
}

example:
user: "I want to meet with my friend john tomorrow and then go to the gym so cancel watching the movie"
assistant:
{
    "code": "0",
    "error_message": "",
    "actions": [
        {
            "add_new_task": {
                "description": "meet with my friend john tomorrow",
                "due_date": "2024-12-25",
                "title": "meet with my friend john before going to the gym"
            }
        },
        {
            "add_new_task": {
                "description": "go to the gym",
                "due_date": "2024-12-25", 
                "title": "go to the gym after meeting with my friend john"
            }
        },
        {
            "delete_task": {
                "task_id": "xxx"
            }
        }
    ]
}
where: time is tomorrow (you can reference the current time to extract the time of tomorrow), title is "meet with my friend", description is "meet with my friend", due_date is calculated time of tomorrow, task_id is the id of the task to mark as complete or delete.

ensure always return the output in valid JSON format.
no additional text or anything else.
current time: ${DateTime.now().toIso8601String()}
        ''',
      ),
      if (actions.contains(ActionType.complete_task) || actions.contains(ActionType.delete_task)) ...[
        ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string("""
          current todos:\n${_appState.todos.map((e) => "- id: ${e.id}, title: ${e.title}, due_date: ${e.dueDate}, is_completed: ${e.isCompleted}").join('\n')}
          """)
        ),
      ],
      if (actions.contains(ActionType.change_app_color_theme)) ...[
        ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string("""
          current theme: ${_appState.theme.name}
          available themes: ${AppTheme.presets.map((e) => e.name).join(', ')}
          """)
        ),
      ],
      ChatCompletionMessage.user(
        content: ChatCompletionUserMessageContent.string(message)
      ),
    ];
    try {
      final response = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId('moonshot-v1-8k'),
          messages: messages,
          temperature: 0,
        ),
      );

      final result = response.choices.first;
      final content = jsonDecode(result.message.content ?? "{}") as Map<String, dynamic>;
      final code = content["code"] as String;
      final errorMessage = content["error_message"] as String;
      final actions = content["actions"] as List<dynamic>;

      if (code == "0") {
        return (actions.map((action) {
          final entry = (action as Map<String, dynamic>).entries.first;
          return ChatFunctionCall(
            name: entry.key,
            arguments: entry.value as Map<String, dynamic>
          ).parseArguments() as LLMDecision;
        }).toList(), null);
      } else {
        return (null, errorMessage);
      }
      
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      return (null, "خاتالىق يۈز بەردى: $e");
    }
  }

  Stream<String> streamMessage(String message) async* {
    // Add user message to history
    addMessage(message, true);
    yield "";

    List<ActionType> actions = (await decideAction(message)).where((element) => element != ActionType.nothing).toList();
    if (actions.isNotEmpty) {
      final (decisions, errorMessage) = await extractActions(message, actions);
      if (decisions != null) {
        for (final decision in decisions) {
          decision.execute(_appState);
        }
      } else {
        yield errorMessage!;
      }
    }
    try {
      // Prepare messages including system prompt and recent history
      final messages = [ 
        const ChatCompletionMessage.system(
          content: '''You are a helpful assistant for a TODO app. You can:
          - Add new tasks
          - Mark tasks as complete
          - Delete tasks
          - Undo previous operation
          - Change app color theme
          - Help with app usage
          ''',
        ),
        // Add recent conversation history
        ..._messageHistory.map((msg) => msg.role == ChatMessageRole.user ? ChatCompletionMessage.user(content: ChatCompletionUserMessageContent.string(msg.content)) : ChatCompletionMessage.assistant(content: msg.content)),
        if (actions.isNotEmpty) ChatCompletionMessage.system(
          content: '''
User asks: $message
Our system performs the following actions: ${actions.map((e) => e.name).join(', ')} based on user requrements.
tell user their request is being processed, don't ask questions.
          '''
        ),
      ];

      final stream = await _client.createChatCompletionStream(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.modelId('moonshot-v1-8k'),
          messages: messages,
          stream: true,
          temperature: 0.7,
        ),
      );

      String fullResponse = '';
      await for (final response in stream) {
        if (response.choices.isNotEmpty) {
          final content = response.choices.first.delta.content;
          if (content != null) {
            fullResponse += content;
            yield content;
          }
        }
      }
      
      // Add assistant's complete response to history
      addMessage(fullResponse, false);
    } catch (e) {
      final errorMessage = 'خاتالىق يۈز بەردى: $e';
      addMessage(errorMessage, false);
      yield errorMessage;
    }
  }

  void clearHistory() {
    _messageHistory.clear();
  }

  void dispose() {
    _messageHistory.clear();
    _client.endSession();
  }
}

class ChatMessage {
  final String content;
  final ChatMessageRole role;
  final bool isLoading;

  ChatMessage({
    required this.content,
    required this.role,
    this.isLoading = false,
  });
}

