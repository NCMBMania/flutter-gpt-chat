// パッケージのインポート
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:ncmb/ncmb.dart';

// チャットページのウィジェットを定義
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  // StatefulWidgetを継承すると、Stateを作成するメソッドが必要になります
  @override
  State<ChatPage> createState() => _ChatPageState();
}

// _ChatPageStateクラスを定義
class _ChatPageState extends State<ChatPage> {
  // メッセージのリストを作成
  List<types.TextMessage> _messages = [];
  // ユーザーオブジェクトを作成
  final _user = const types.User(id: 'user');

  // 初期化時にメッセージをロード
  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  // メインのUI構造を作成
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          showUserAvatars: false,
          showUserNames: false,
          user: _user,
        ),
      );

  // メッセージを追加する関数
  void _addMessage(types.TextMessage message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  // NCMBObjectをTextMessageに変換する関数
  types.TextMessage _toMessage(NCMBObject obj) {
    return types.TextMessage(
      author: types.User(id: obj.getString('role', defaultValue: 'user')),
      createdAt: obj.getDateTime('createDate').microsecondsSinceEpoch,
      id: obj.objectId!,
      text: obj.getString('content'),
    );
  }

  // メッセージ送信時に呼ばれる関数
  void _handleSendPressed(types.PartialText message) async {
    // メッセージを保存
    var obj = NCMBObject('Chat');
    obj.set('content', message.text);
    obj.set('role', 'user');
    await obj.save();
    // メッセージをチャット画面に追加
    _addMessage(_toMessage(obj));
    // 過去のメッセージ内容を作成
    final messages = _messages
        .map((message) => {
              'role': message.author.id,
              'content': message.text,
            })
        .toList();
    // OpenAIのAPIを呼び出す
    var script = NCMBScript('text.js')
        .body('content', message.text)
        .body('messages', messages);
    var res = (await script.post()) as Map<String, dynamic>;
    // OpenAIの返答を保存
    var answer = NCMBObject('Chat');
    answer.set('content', res['text'] as String);
    answer.set('role', 'assistant');
    await answer.save();
    // OpenAIの返答をチャット画面に追加
    _addMessage(_toMessage(answer));
  }

  // 過去のメッセージをロードする関数
  void _loadMessages() async {
    // メッセージを取得するクエリを作成
    var query = NCMBQuery('Chat');
    // 1日前以降のメッセージを取得
    var date = DateTime.now().subtract(const Duration(days: 1));
    query.greaterThanOrEqualTo('createDate', date);
    query.order('createDate', descending: true); // 古いデータが上に来るようにする
    var ary = (await query.fetchAll()).map((o) => o as NCMBObject).toList();
    // 取得したNCMBObjectのリストをTextMessageに変換
    final messages = ary.map((e) => _toMessage(e)).toList();
    // メッセージを更新
    setState(() {
      _messages = messages;
    });
  }
}
