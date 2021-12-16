import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'package:camera/camera.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:erp/utils/constantes/sistema.constante.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:erp/compartilhados/componentes/assinatura/assinatura.componente.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/models/os/finalizar-os.modelo.dart';
import 'package:erp/models/os/grid-finalizacao-tecnico-x-servico.modelo.dart';
import 'package:erp/models/os/os-config.modelo.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/servicos/ordem-servico/ordem-servico.servicos.dart';
import 'package:erp/telas/ordem-servico/finalizar/status-checklist-servico-modal.componente.dart';
import 'package:erp/utils/constantes/mascaras.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/compartilhados/animate/fadein.componente.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/compartilhados/componentes/button/button.componente.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:erp/utils/request.util.dart';
import 'package:erp/utils/screen_util.dart';
import 'package:flutter/material.dart';
import 'package:erp/utils/validators.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class FinalizarOSTela extends StatefulWidget {
  final OSConfig osConfig;
  final int osId;
  final int status;
  final int osXTecId;
  const FinalizarOSTela({Key key, this.osId, this.status, this.osXTecId, this.osConfig}) : super(key: key);

  @override
  _FinalizarOSTelaState createState() => _FinalizarOSTelaState();
}

class _FinalizarOSTelaState extends State<FinalizarOSTela> {
  LocalizacaoServico _locale = new LocalizacaoServico();
  Stream<dynamic> _streamCheckServico;
  List<GridFinalizacaoTecnicoXServicoModelo> _servicosVinculadosList = new List<GridFinalizacaoTecnicoXServicoModelo>();
  FinalizarTecnicoOSModelo _finalizarOSObjeto = new FinalizarTecnicoOSModelo();
  Position _posicaoAtual = new Position();

  Helper helper = new Helper();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _documento = '';
  String _nomeRecebedor = '';
  String _descricao = '';

  List<File> _listaAssinaturas = new List<File>();
  // List<ByteData> _listaAssinaturas = new List<ByteData>();
  // List<String> _listaAssinaturas = new List<String>();

  List<File> _listaImagens = new List<File>();

  int _assinaturasCounter = 0;
  int _imagensCounter = 0;
  int _tecnicoId;
  RequestUtil _requestUtil = new RequestUtil();

  int osID;
  var _cpfMaskController = new MaskedTextController(mask: MascarasConstantes.CPF);
  TextEditingController _nomeController = new TextEditingController();
  TextEditingController _descricaoSolucaoController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _autoValidacao = false;

  bool _isOnline = true;

  _FinalizarOSTelaState() {}

  @override
  void initState() {
    super.initState();
    osID = widget.osId;
    _locale.iniciaLocalizacao(context);
    _streamCheckServico = Stream.fromFuture(_fazRequest());
    _requestUtil.verificaOnline()
      .then((value) {
        _isOnline = value;
      });
    _adquireTecnicoId();
  }

  Future<dynamic> _fazRequest() async {
    dynamic requestServicosVinculados = await OrdemServicoService().getGridFinalizacaoTecnicoXServico(
      osId: osID,
      osXTecId: widget.osXTecId
    );

    requestServicosVinculados.forEach((data) {
      _servicosVinculadosList.add(GridFinalizacaoTecnicoXServicoModelo.fromJson(data));
    });

    return _servicosVinculadosList;
  }

  @override
  Widget build(BuildContext context) {
     bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(_locale.locale[TraducaoStringsConstante.Finalizar].toUpperCase()),
            ),
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                autovalidate: _autoValidacao,
                child: _finalizarOSForm()
              ),
            ),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        },
      ),
    );
  }

  Widget _finalizarOSForm() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(8),
          child: TextFormField(
            controller: _nomeController,
            decoration: CampoTextoDecoration(label: _locale.locale[TraducaoStringsConstante.NomeRecebedor]),
            keyboardType: TextInputType.text,
            validator: (input) {
              if (input.length > 3 && input.isNotEmpty) {
                return null;
              } else {
                return "${_locale.locale['NomeValidacao']}";
              }
            },
            onSaved: (input) => _nomeRecebedor = input,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: TextFormField(
            controller: _cpfMaskController,
            decoration: CampoTextoDecoration(label: "${_locale.locale['CPF']}",),
            maxLength: 14,
            keyboardType: TextInputType.phone,
            validator: (input) {
              if (widget.osConfig.cpfObrigatorio == true) {
                if (Validators().cpfValidator(input)) {
                  return null;
                } else {
                  return "${_locale.locale['CPFInvalido']}";
                }
              }
              else if (input.isNotEmpty) {
                if (Validators().cpfValidator(input)) {
                  return null;
                } else {
                  return "${_locale.locale['CPFInvalido']}";
                }

              }
              else {
                return null;
              }
            },
            onSaved: (input) {
              String valor;
              valor = input.replaceAll(".", "");
              valor = valor.replaceAll("/", "");
              valor = valor.replaceAll("-", "");
              _documento = valor;
            },
          ),
        ),
         Visibility(
          visible: widget.osConfig.servicoPorTecnico && _isOnline,
          child: _listagemServicosVinculados()
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: TextFormField(
            controller: _descricaoSolucaoController,
            maxLines: 4,
            decoration: CampoTextoDecoration(label: _locale.locale[TraducaoStringsConstante.DescricaoSolucao]),
            keyboardType: TextInputType.text,
            validator: (input) {
              if (input.isNotEmpty) {
                return null;
              } else {
                return _locale.locale[TraducaoStringsConstante.DescricaoSolucaoValidacao];
              }
            },
            onSaved: (input) {
              _descricao = input;
            },
          ),
        ),
        _assinaturasBox(),
        _imagensBox(),
        _botaoSalvar(),
      ],
    );
  }

  Widget _childStreamConexao({BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return Container();
    }
    else if (_servicosVinculadosList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
      return Carregando();
    }
    else if (_servicosVinculadosList.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return Container();
    }
    else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Texto(
                  _locale.locale[TraducaoStringsConstante.ServicosExecutados],
                  bold: true,
                  fontSize: 18
                )
              ],
            ),
            ListView.separated(
              shrinkWrap: true,
              separatorBuilder: (BuildContext context, int index) =>
              Divider(thickness: 2,height: 0,),
              itemBuilder: (context, index) {
                return _listaServicosVinculados(context, index, _servicosVinculadosList[index]);
              },
              itemCount: _servicosVinculadosList.length,
            ),
          ],
        ),
      );
    }
  }

  Widget _listagemServicosVinculados() {
    return StreamBuilder(
      stream: _streamCheckServico,
      builder: (context, snapshot) {
        return _childStreamConexao(context: context, snapshot: snapshot);
      },
    );
  }

  Widget _listaServicosVinculados(BuildContext context, int index, GridFinalizacaoTecnicoXServicoModelo itemServico) {
    bool _retornaStatusServico(int statusNumero) {
      switch (statusNumero) {
        case 0:
          return false;
          break;
        case 1:
          return true;
          break;
        default:
          return true;
          break;
      }
    }

    int _alteraStatusServico(bool status) {
      if (status == true) {
        return 1;
      }
      else {
        return 0;
      }
    }

    return InkWell(
      onTap: () async {
        final resultado = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StatusCheckListServicoModalComponente(
              osXTecXServId: itemServico.id,
              osXMatId: itemServico.osXMatId,
              osXTecId: widget.osXTecId,
            )
          ),
        );
        if (resultado == null) {
          setState(() {
            _servicosVinculadosList.clear();
          });
          _streamCheckServico = Stream.fromFuture(_fazRequest());
        }
      },
      child: Container(
        color: itemServico.checkListPendente > 0 ? Colors.red[300] : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Checkbox(
                  value: _retornaStatusServico(itemServico.status),
                  onChanged: (bool status) async{
                    AtualizarStatusServicoXTecnicoModelo atualizaStatusObjeto = new AtualizarStatusServicoXTecnicoModelo();
                    Data dataAtualizacao = new Data();
                    atualizaStatusObjeto.data = dataAtualizacao;

                    atualizaStatusObjeto.status = _alteraStatusServico(status);
                    atualizaStatusObjeto.data.id = itemServico.id;
                    atualizaStatusObjeto.data.osXMatId = itemServico.osXMatId;
                    atualizaStatusObjeto.data.osxTecId = widget.osXTecId;
                    atualizaStatusObjeto.data.servicoId = itemServico.servicoId;
                    atualizaStatusObjeto.data.codigo = itemServico.codigo;
                    atualizaStatusObjeto.data.descricao = itemServico.descricao;
                    atualizaStatusObjeto.data.status = itemServico.status;
                    atualizaStatusObjeto.data.checkListTotal = itemServico.checkListTotal;
                    atualizaStatusObjeto.data.checkListPendente = itemServico.checkListPendente;
                    atualizaStatusObjeto.data.dataStatus = itemServico.dataStatus;
                    atualizaStatusObjeto.data.quantidade = itemServico.quantidade;
                    atualizaStatusObjeto.data.tecnicoId = itemServico.tecnicoId;

                    String atualizaStatusObjetoJson = json.encode(atualizaStatusObjeto.toJson());
                    if(!await _requestUtil.verificaOnline()) {
                      bool resposta = await OrdemServicoService().atualizarStatusServicoXTecnico(
                        context: context,
                        checkServico: atualizaStatusObjetoJson
                      );

                      if (resposta == true) {
                        setState(() {
                          // itemServico.status = _alteraStatusServico(status);
                          _servicosVinculadosList.clear();
                        });
                        _streamCheckServico = Stream.fromFuture(_fazRequest());
                      }
                    }
                    else {
                      Response resposta = await OrdemServicoService().atualizarStatusServicoXTecnico(
                        context: context,
                        checkServico: atualizaStatusObjetoJson
                      );

                      if (resposta.statusCode == 200) {
                        setState(() {
                          // itemServico.status = _alteraStatusServico(status);
                          _servicosVinculadosList.clear();
                        });
                        _streamCheckServico = Stream.fromFuture(_fazRequest());
                      }
                    }
                  }
                ),
              ),
              Flexible(
                flex: 10,
                child: Texto(itemServico.descricao)
              ),
              Flexible(
                child: Texto((itemServico.checkListTotal - itemServico.checkListPendente).toString() + '/' + itemServico.checkListTotal.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _assinaturasBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Texto(_locale.locale[TraducaoStringsConstante.Assinaturas], bold: true),
          _listaAssinaturas.length > 0
            ? GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              physics: NeverScrollableScrollPhysics(),
              children: List.generate(
                  _listaAssinaturas.length,
                  (index) {
                    return InkWell(
                      onTap: () {
                        _removerAssinatura(index: index, arquivo: _listaAssinaturas[index]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(_listaAssinaturas[index]),
                          ),
                          border: Border.all(width: 1, color: Colors.black)
                        ),
                      ),
                    );
                  }
                )
            )
            : Container(),
          RaisedButton(
            child: Texto(_locale.locale[TraducaoStringsConstante.AdicionarAssinaturas]),
            onPressed: () async {
              final resultado = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AssinaturaComponente(
                  idObjetoAssinatura: widget.osId, numero: _assinaturasCounter,
                ))
              );

              if (resultado != null) {
                setState(() {
                  _listaAssinaturas.add(resultado);
                });
                _assinaturasCounter++;
              }
            }
          )
        ],
      ),
    );
  }

  _removerAssinatura({int index, File arquivo}) async {
    bool resultado;
    resultado = await AlertaComponente().showAlertaConfirmacao(
      context: context,
      mensagem: _locale.locale[TraducaoStringsConstante.DeletarAssinaturaConfirmacao]
    );
    
    if (resultado == true) {
      setState(() {
        _listaAssinaturas.removeAt(index);
        arquivo.deleteSync();
      });
    }
  }

  Widget _imagensBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Texto(_locale.locale[TraducaoStringsConstante.ImagensAdicionais], bold: true),
          _listaImagens.length > 0
            ? GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              physics: NeverScrollableScrollPhysics(),
              children: List.generate(
                  _listaImagens.length,
                  (index) {
                    return InkWell(
                      onTap: () {
                        _removerFoto(index: index, arquivo: _listaImagens[index]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(_listaImagens[index]),
                          ),
                          border: Border.all(width: 1, color: Colors.black)
                        ),
                      ),
                    );
                  }
                )
            )
            : Container(),
          RaisedButton(
            child: Texto(_locale.locale[TraducaoStringsConstante.AdicionarImagens]),
            onPressed: () async {
              File _imagem;
              final _picker = ImagePicker();
              final _fotoTirada = await _picker.getImage(source: ImageSource.camera);

              if(_fotoTirada != null) {
                final Directory saida = await getTemporaryDirectory();
                _imagem = File(_fotoTirada.path);
                File newImagem = await _imagem.copy('${saida.path}/foto_${_imagensCounter}_os_${widget.osId}.jpg');
                await _imagem.delete();
                setState(() {
                  _listaImagens.add(newImagem);
                });
                _imagensCounter++;
              }
            }
          )
        ],
      ),
    );
  }

  _removerFoto({int index, File arquivo}) async {
    bool resultado;
    resultado = await AlertaComponente().showAlertaConfirmacao(
      context: context,
      mensagem: _locale.locale[TraducaoStringsConstante.DeletarFotoConfirmacao]
    );
    
    if (resultado == true) {
      setState(() {
        _listaImagens.removeAt(index);
        arquivo.deleteSync();
      });
    }
  }

  bool _verificaServicosPendentes() {
    bool retorno = true;
    for(GridFinalizacaoTecnicoXServicoModelo item in _servicosVinculadosList) {
      if (item.checkListPendente != 0 && item.status == 1) {
        retorno = false;
        break;
      }
    }
    return retorno;
  }

  bool _verificaAssinaturasExistentes() {
    bool retorno = false;
    if (widget.status == StatusOrdemDeServico.FinalizacaoSemSucessoTecnico) {
      retorno = true;
    }
    else {
      if (_listaAssinaturas.length == 0) {
        retorno = false;
      }
      else {
        retorno = true;
      }
    }
    return retorno;
  }

  bool _verificaFotosExistentes() {
    bool retorno = false;
    if (_listaImagens.length == 0) {
      retorno = false;
    }
    else {
      retorno = true;
    }
    return retorno;
  }

  Widget _botaoSalvar() {
    return ButtonComponente(
      funcao: () async {
        if (_submit() == true) {
          if(await _salvar() == true) {
            final Directory tempDirDeletar = await getTemporaryDirectory();
            tempDirDeletar.deleteSync(recursive: true);
            // Navigator.pop(context, true);
            // Navigator.pop(context, true);
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context, true);
          }
        }
      },
      ladoIcone: 'Esquerdo',
      imagemCaminho: AssetsIconApp.Add,
      somenteTexto: true,
      somenteIcone: false,
      texto: _locale.locale['Salvar'],
      backgroundColor: Colors.blue,
      textColor: Colors.white
    );
  }

  _adquirirLocalizacaoAtual() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
      .then((Position position) {
        _posicaoAtual = position;
      })
      .catchError((e) {
        print(e);
      });
  }

  // Future<Position> _adquirirLocalizacaoAtual() async {
  //   final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  //   return await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  // }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(text)));
  }

  List<Arquivos> _converteArquivos() {
    List<Arquivos> _arquivosLista = new List<Arquivos>();
    for (int i = 0; i < _listaAssinaturas.length; i++) {
      Arquivos arquivo = new Arquivos();
      final encoded = base64.encode(_listaAssinaturas[i].readAsBytesSync());
      arquivo.arquivo = encoded;
      arquivo.fileName = 'assinatura_${i}_os${widget.osId}.png';
      arquivo.contentType = 'image/png';
      arquivo.size = ((encoded.replaceAll('=', '').length / 4) * 3);
      arquivo.tipo = 3;

      _arquivosLista.add(arquivo);
    }

    for (int i = 0; i < _listaImagens.length; i++) {
      Arquivos arquivo = new Arquivos();
      final encoded = base64.encode(_listaImagens[i].readAsBytesSync());
      arquivo.arquivo = encoded;
      arquivo.fileName = 'foto_${i}_os${widget.osId}.png';
      arquivo.contentType = 'image/jpg';
      arquivo.size = ((encoded.replaceAll('=', '').length / 4) * 3);
      arquivo.tipo = 1;

      _arquivosLista.add(arquivo);
    }
    return _arquivosLista;
  }

  Future<void> _adquireTecnicoId() async {
    int tecnico;
    tecnico = await _requestUtil.obterIdUsuarioSharedPreferences();
    _tecnicoId = tecnico;
  }

  bool _submit() {
    bool checkServicos = _verificaServicosPendentes();
    bool assinaturas = _verificaAssinaturasExistentes();
    bool fotos = _verificaFotosExistentes();

    if (_formKey.currentState.validate()) {
      if (checkServicos == false && widget.osConfig.servicoPorTecnico == true) {
        setState(() {
          _showSnackBar(_locale.locale[TraducaoStringsConstante.ChecklistsValidacao]);
          _autoValidacao = true;
        });
        return false;
      }
      else if (assinaturas == false) {
        setState(() {
          _showSnackBar(_locale.locale[TraducaoStringsConstante.AssinaturaObrigatorio]);
          _autoValidacao = true;
        });
        return false;
      }
      else if (fotos == false && widget.osConfig.fotoObrigatoria == true) {
        setState(() {
          _showSnackBar(_locale.locale[TraducaoStringsConstante.FotoObrigatoria]);
          _autoValidacao = true;
        });
        return false;
      }
      else {
        _formKey.currentState.save();

        _adquirirLocalizacaoAtual();
        // _posicaoAtual = await _adquirirLocalizacaoAtual();

        _adquireTecnicoId();

        _finalizarOSObjeto.osId = widget.osId;
        _finalizarOSObjeto.osxTecId = widget.osXTecId;
        _finalizarOSObjeto.status = widget.status;
        _finalizarOSObjeto.tecnicoId = _tecnicoId;
        _finalizarOSObjeto.latitude = _posicaoAtual.latitude ?? 0;
        _finalizarOSObjeto.longitude = _posicaoAtual.longitude ?? 0;
        _finalizarOSObjeto.nome = _nomeRecebedor ?? '';
        _finalizarOSObjeto.cpf = _documento ?? '';
        _finalizarOSObjeto.descricao = _descricao ?? '';

        _finalizarOSObjeto.arquivos = _converteArquivos();
        
        return true;
      }
    } else {
      setState(() {
        _showSnackBar(_locale.locale['PreenchaCamposObrigatorios']);
        _autoValidacao = true;
      });
      return false;
    }
  }

  Future<bool> _salvar() async {
    bool resultado;
    String finalizacaoOSJson = json.encode(_finalizarOSObjeto.toJson());
    if(!await _requestUtil.verificaOnline()) {
      bool request = await OrdemServicoService().finalizarOS(finalizacaoOS: finalizacaoOSJson, context: context);
      resultado = request;
    }
    else {
      Response request = await OrdemServicoService().finalizarOS(finalizacaoOS: finalizacaoOSJson, context: context);
      if (request.statusCode == 200) resultado = true;
      else resultado = false;
    }
    return resultado;
  }
}
