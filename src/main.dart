import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:teledart/model.dart';
import 'dart:math';
import 'dart:async';
import 'dart:io' show Platform;


const String PRIVATE = "private";
const String SUPERGROUP = "supergroup";
const String GROUP = "group";

const String CREATOR = "creator";
const String ADMINISTRATOR = "administrator";
const String MEMBER = "member";
const String RESTRICTED = "restricted";
const String LEFT = "left";
const String KICKED = "kicked";

void handle_dice(message, Telegram telegram) async {
    var dice = message.dice;
    if (dice.emoji == "🎯" && dice.value == 6) {
        // get username
        var user = message.from;
        if (user == null) {
            print("Dice sent by nobody");
            return;
        }
        String username = user.username ?? "anonymous user";
        print("'$username' won!");
        if (message.chat.type == SUPERGROUP) {
            var chat_id = message.chat.id;
            var user_id = user.id;
            var chat_member_future = telegram.getChatMember(chat_id, user_id);
            await new Future.delayed(const Duration(seconds: 30));
            chat_member_future.then((chat_member) {
                switch (chat_member.status) {
                    case ADMINISTRATOR:
                    case CREATOR:
                        {
                            message.reply(
                                "Ich kann Dich zwar nicht muten, aber sei doch bitte so lieb und halt trotzdem eine Woche lang die Fresse.");
                        }
                        break;

                    case MEMBER:
                    case RESTRICTED:
                    case KICKED:
                        {
                            List<String> msgs = ["Jawollo!",
                                "Gewinner, Gewinner, Huhn Abendessen!",
                                "Viel Spaß bei einer Woche Urlaub von RWTH Informatik!",
                                "endlich"];
                            var rng = new Random();
                            var random = rng.nextInt(msgs.length);
                            message.reply(msgs[random]);
                            var permissions = new ChatPermissions(
                                can_send_messages: false);
                            var date = DateTime
                                .now()
                                .millisecondsSinceEpoch;
                            var until_date = (date / 1000).round() +
                                (7 * 24 * 60 * 60);
                            print("banning until $until_date");
                            var banned = telegram.restrictChatMember(
                                chat_id, user_id,
                                permissions: permissions,
                                until_date: until_date);
                            banned.then((bool value) => print(value))
                                .catchError((e) => print(e));
                        }
                        break;

                    case LEFT:
                        {
                            message.reply(
                                "Schade dass Du schon weg bist. Ich werde Deinen Gewinn aufbewahren und einlösen, wenn Du uns wieder besuchst!");
                        }
                        break;
                }
            }, onError: (e) {
                print("Can't get a chat member.");
            });
        }
        else {
            await new Future.delayed(const Duration(seconds: 3));
            message.reply(
                "Guter Wurf! Aber jetzt genug geübt, probier dein Glück in der Hauptgruppe!");
        }
    }
}


void main() {
    var token = Platform.environment["BOT_TOKEN"];
    var telegram = Telegram(token);
    var teledart = TeleDart(telegram, Event());

    teledart.start().then((me) => print('${me.username} is initialised'));

    teledart
        .onMessage()
        .listen((message) {
        if (message.dice != null) {
            handle_dice(message, telegram);
        }
    } );
}
