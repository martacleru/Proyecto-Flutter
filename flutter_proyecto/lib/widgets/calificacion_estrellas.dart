// WIDGET DE CALIFICACIÓN CON ESTRELLAS - Componente interactivo para calificar libros

import 'package:flutter/material.dart';

class CalificacionEstrellas extends StatefulWidget {
  final double calificacion; // Calificación actual (0-5)
  final Function(double) onCalificacionCambiada; // Callback cuando cambia la calificación
  final double tamano; // Tamaño de las estrellas
  final bool editable; // Si es editable o solo lectura

  const CalificacionEstrellas({
    super.key,
    required this.calificacion,
    required this.onCalificacionCambiada,
    this.tamano = 30,
    this.editable = true,
  });

  @override
  State<CalificacionEstrellas> createState() => _CalificacionEstrellasState();
}

class _CalificacionEstrellasState extends State<CalificacionEstrellas> {
  double _calificacionTemp = 0.0; // Calificación temporal para feedback visual

  @override
  void initState() {
    super.initState();
    _calificacionTemp = widget.calificacion; // Inicializar con calificación actual
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // BOTÓN PARA 0 ESTRELLAS (solo en modo editable)
            if (widget.editable) ...[
              GestureDetector(
                onTap: () {
                  setState(() {
                    _calificacionTemp = 0.0; // Reiniciar calificación
                  });
                  widget.onCalificacionCambiada(0.0); // Notificar cambio
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _calificacionTemp == 0.0 
                        ? Colors.red.withOpacity(0.2) 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _calificacionTemp == 0.0 
                          ? Colors.red 
                          : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.clear,
                    size: widget.tamano * 0.6,
                    color: _calificacionTemp == 0.0 
                        ? Colors.red 
                        : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            
            // LAS 5 ESTRELLAS PRINCIPALES
            ...List.generate(5, (index) {
              final double valorEstrella = index + 1.0; // Valor de estrella completa
              final double valorMedia = valorEstrella - 0.5; // Valor de media estrella
              
              return GestureDetector(
                onTap: widget.editable ? () {
                  // LÓGICA DE CALIFICACIÓN: toggle entre completa y media
                  if (_calificacionTemp == valorEstrella) {
                    setState(() {
                      _calificacionTemp = valorMedia; // Cambiar a media estrella
                    });
                    widget.onCalificacionCambiada(valorMedia);
                  } else {
                    setState(() {
                      _calificacionTemp = valorEstrella; // Cambiar a estrella completa
                    });
                    widget.onCalificacionCambiada(valorEstrella);
                  }
                } : null,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: _buildEstrellaIndividual(
                    valorCompleto: valorEstrella,
                    valorMedia: valorMedia,
                  ),
                ),
              );
            }),
          ],
        ),
        
        // TEXTO DE CALIFICACIÓN NUMÉRICA (solo en modo editable)
        if (widget.editable) ...[
          const SizedBox(height: 8),
          Text(
            '${_calificacionTemp.toStringAsFixed(1)}/5.0', // Mostrar con 1 decimal
            style: TextStyle(
              fontSize: widget.tamano * 0.35,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  // CONSTRUIR ESTRELLA INDIVIDUAL CON ESTADO VISUAL
  Widget _buildEstrellaIndividual({
    required double valorCompleto,
    required double valorMedia,
  }) {
    final bool estaCompleta = _calificacionTemp >= valorCompleto;
    final bool esMedia = _calificacionTemp >= valorMedia && _calificacionTemp < valorCompleto;
    final bool estaVacia = _calificacionTemp < valorMedia;

    if (esMedia) {
      // MEDIA ESTRELLA: usar Stack para superponer mitades
      return Stack(
        children: [
          // PARTE DE ATRÁS (vacia)
          Icon(
            Icons.star_border,
            color: Colors.grey[400],
            size: widget.tamano,
          ),
          // MITAD IZQUIERDA (llena)
          ClipRect(
            clipper: _MitadIzquierdaClipper(), // Clipper personalizado
            child: Icon(
              Icons.star,
              color: Colors.amber,
              size: widget.tamano,
            ),
          ),
        ],
      );
    } else if (estaCompleta) {
      // ESTRELLA COMPLETA
      return Icon(
        Icons.star,
        color: Colors.amber,
        size: widget.tamano,
      );
    } else {
      // ESTRELLA VACÍA
      return Icon(
        Icons.star_border,
        color: Colors.grey[400],
        size: widget.tamano,
      );
    }
  }
}

// CLIPPER PERSONALIZADO PARA MEDIA ESTRELLA
class _MitadIzquierdaClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width / 2, size.height); // Solo mitad izquierda
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false; // No necesita recortar nuevamente
  }
}