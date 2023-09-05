import 'package:hive/hive.dart';
import 'database.dart';
// import 'your_user_model_file.dart';

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0; // Unique ID for this adapter

  @override
  User read(BinaryReader reader) {
    return User(
      userId: reader.read(),
      token: reader.read(),
      name: reader.read(),
      email: reader.read(),
      imageUrl: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.write(obj.userId);
    writer.write(obj.token);
    writer.write(obj.name);
    writer.write(obj.email);
    writer.write(obj.imageUrl);
  }
}
