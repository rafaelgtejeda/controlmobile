class Reagendar {
  int _osId;
  int _osxTecId;
  String _motivo;
  String _dataIn;
  String _dataFim;
  int _usuarioId;

  Reagendar(
      {
        int osId,
        int osxTecId,
        String motivo,
        String dataIn,
        String dataFim,
        int usuarioId
      }) {
    this._osId = osId;
    this._osxTecId = osxTecId;
    this._motivo = motivo;
    this._dataIn = dataIn;
    this._dataFim = dataFim;
    this._usuarioId = usuarioId;
  }

  int get osId => _osId;
  set osId(int osId) => _osId = osId;
  int get osxTecId => _osxTecId;
  set osxTecId(int osxTecId) => _osxTecId = osxTecId;
  String get motivo => _motivo;
  set motivo(String motivo) => _motivo = motivo;
  String get dataIn => _dataIn;
  set dataIn(String dataIn) => _dataIn = dataIn;
  String get dataFim => _dataFim;
  set dataFim(String dataFim) => _dataFim = dataFim;
  int get usuarioId => _usuarioId;
  set usuarioId(int usuarioId) => _usuarioId = usuarioId;

  Reagendar.fromJson(Map<String, dynamic> json) {
    _osId = json['osId'];
    _osxTecId = json['osxTecId'];
    _motivo = json['motivo'];
    _dataIn = json['dataIn'];
    _dataFim = json['dataFim'];
    _usuarioId = json['usuarioId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['osId'] = this._osId;
    data['osxTecId'] = this._osxTecId;
    data['motivo'] = this._motivo;
    data['dataIn'] = this._dataIn;
    data['dataFim'] = this._dataFim;
    data['usuarioId'] = this._usuarioId;
    return data;
  }
}
