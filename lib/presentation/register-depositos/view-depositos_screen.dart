import 'package:flutter/material.dart';

class ViewDepositosScreen extends StatefulWidget {
  const ViewDepositosScreen({super.key});

  @override
  State<ViewDepositosScreen> createState() => _ViewDepositosScreenState();
}

class _ViewDepositosScreenState extends State<ViewDepositosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta de Depósitos'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeaderSection(),
                
                // Search Form
                _buildSearchFormSection(),
                
                // Results Section
                _buildResultsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
  return Container(
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
    ),
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Icon(Icons.attach_money, size: 28, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded( // Widget clave para evitar overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Consulta de Depósitos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                softWrap: true, // Añadir wrap para texto largo
              ),
              Text(
                'Busque y visualice los depósitos registrados',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
  Widget _buildSearchFormSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Criterios de Búsqueda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildEmpresaDropdown(),
              _buildBancoDropdown(),
              _buildFechaInicioField(),
              _buildFechaFinField(),
              _buildClienteField(),
              _buildEstadoDropdown(),
              _buildSearchButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resultados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf),
                    onPressed: () {},
                    tooltip: 'Exportar PDF',
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '0 registros encontrados',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Cliente')),
                DataColumn(label: Text('Banco')),
                DataColumn(label: Text('Empresa')),
                DataColumn(label: Text('Importe')),
                DataColumn(label: Text('Moneda')),
                DataColumn(label: Text('Fecha Ingreso')),
                DataColumn(label: Text('Num. Transaccion')),
                DataColumn(label: Text('Estado')),
                DataColumn(label: Text('Acciones')),
              ],
              rows: const [], // Datos vacíos por ahora
            ),
          ),
        ],
      ),
    );
  }

  // Widgets de los campos del formulario (ejemplos)
  Widget _buildEmpresaDropdown() {
    return SizedBox(
      width: 200,
      child: DropdownButtonFormField(
        decoration: const InputDecoration(labelText: 'Empresa'),
        items: [],
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildBancoDropdown() {
    return SizedBox(
      width: 200,
      child: DropdownButtonFormField(
        decoration: const InputDecoration(labelText: 'Banco'),
        items: [],
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildFechaInicioField() {
    return SizedBox(
      width: 200,
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Desde',
          suffixIcon: Icon(Icons.calendar_today)),
        readOnly: true,
        onTap: () => _selectDate(context),
      ),
    );
  }

  Widget _buildFechaFinField() {
    return SizedBox(
      width: 200,
      child: TextFormField(
        decoration: const InputDecoration(
          labelText: 'Hasta',
          suffixIcon: Icon(Icons.calendar_today),
        ),
        readOnly: true,
        onTap: () => _selectDate(context),
      ),
    );
  }

  Widget _buildClienteField() {
    return SizedBox(
      width: 300,
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          return [];
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              labelText: 'Cliente',
              suffixIcon: Icon(Icons.search),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEstadoDropdown() {
    return SizedBox(
      width: 200,
      child: DropdownButtonFormField(
        decoration: const InputDecoration(labelText: 'Estado'),
        items: [],
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.search, size: 18),
      label: const Text('Buscar/Actualizar'),
      onPressed: () {},
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {}
  }
}