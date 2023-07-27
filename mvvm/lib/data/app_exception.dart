class AppExcapntion implements Exception{
  final _message;
  final _prefix ;

  AppExcapntion([this._message, this._prefix]);

  String toString(){
    return '$_prefix$_message';
  } 

}

class FetchDataException extends AppExcapntion{
  FetchDataException([String? message]) : super( message, 'Error During Communication' );
}

class BadRequestException extends AppExcapntion{
  BadRequestException([String? message]) : super( message, 'Invalid Request' );
}

class UnauthorisedExcepton extends AppExcapntion{
  UnauthorisedExcepton([String? message]) : super( message, 'Unauthorised Request' );
}

class InvalidInputdExcepton extends AppExcapntion{
  InvalidInputdExcepton([String? message]) : super( message, 'Invalid Input' );
}