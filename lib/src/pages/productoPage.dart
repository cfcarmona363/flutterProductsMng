import 'dart:io';

import 'package:flutter/material.dart';
import 'package:form_validation/src/bloc/productos_bloc.dart';
import 'package:form_validation/src/bloc/provider.dart';
import 'package:form_validation/src/models/producto_model.dart';
import 'package:form_validation/src/utils/utils.dart';
import 'package:image_picker/image_picker.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _guardando = false;

  File foto;

  ProductosBloc productosBloc;

  ProductModel producto = new ProductModel();

  @override
  Widget build(BuildContext context) {
    productosBloc = Provider.productosBloc(context);

    final ProductModel prodData = ModalRoute.of(context).settings.arguments;

    if (prodData != null) {
      producto = prodData;
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text('Product'), actions: <Widget>[
        IconButton(
          icon: Icon(Icons.photo_size_select_actual),
          onPressed: _seleccionarFoto,
        ),
        IconButton(
          icon: Icon(Icons.camera_alt),
          onPressed: _sacarFoto,
        )
      ]),
      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(15),
            child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    _mostrarFoto(),
                    _crearNombre(),
                    _crearPrecio(),
                    _crearDispobible(),
                    _crearBoton()
                  ],
                ))),
      ),
    );
  }

  Widget _crearNombre() {
    return TextFormField(
        initialValue: producto.titulo,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: 'Producto'),
        onSaved: (value) => producto.titulo = value,
        validator: (value) =>
            value.length < 3 ? 'The name is too short' : null);
  }

  Widget _crearPrecio() {
    return TextFormField(
        initialValue: producto.valor.toString(),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: 'Precio'),
        onSaved: (value) => producto.valor = double.parse(value),
        validator: (value) =>
            isNumeric(value) ? null : 'The value should be numeric');
  }

  Widget _crearDispobible() {
    return SwitchListTile(
      value: producto.disponible,
      title: Text('Available'),
      activeColor: Colors.deepPurple,
      onChanged: (value) => setState(() {
        producto.disponible = value;
      }),
    );
  }

  Widget _crearBoton() {
    return RaisedButton.icon(
      icon: Icon(Icons.save),
      label: Text('Save'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.deepPurple,
      textColor: Colors.white,
      onPressed: _guardando ? null : _submit,
    );
  }

  void _submit() async {
    if (!formKey.currentState.validate()) return;
    formKey.currentState.save();

    setState(() {
      _guardando = true;
    });

    if (foto != null) {
      producto.fotoUrl = await productosBloc.subirFoto(foto);
    }

    if (producto.id != null) {
      productosBloc.editarProducto(producto);
    } else {
      productosBloc.agregarProducto(producto);
    }

    mostrarSnackbar('The product was correctly saved ');
    Navigator.pop(context, setState(() {}));
  }

  void mostrarSnackbar(String mensaje) {
    final snackbar = SnackBar(
      content: Text(mensaje),
      backgroundColor: Colors.deepPurple,
      duration: Duration(milliseconds: 1500),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Widget _mostrarFoto() {
    return producto.fotoUrl != null
        ? FadeInImage(
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: AssetImage('assets/loading.gif'),
            image: NetworkImage(producto.fotoUrl))
        : Image(
            image: AssetImage(foto?.path ?? 'assets/no-image.png'),
            height: 300,
            fit: BoxFit.cover);
  }

  _seleccionarFoto() async {
    _procesarImagen(ImageSource.gallery);
  }

  _sacarFoto() async {
    _procesarImagen(ImageSource.camera);
  }

  _procesarImagen(ImageSource origen) async {
    foto = await ImagePicker.pickImage(source: origen);

    if (foto != null) {
      producto.fotoUrl = null;
    }
    setState(() {});
  }
}
