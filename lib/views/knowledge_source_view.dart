import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/knowledge_source_controller.dart';
import '../core/theme/app_colors.dart';
import '../model/knowledge_source_model.dart';
import '../widgets/loading_widget.dart';
import 'package:file_picker/file_picker.dart';

class KnowledgeSourceView extends StatelessWidget {
  const KnowledgeSourceView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KnowledgeSourceController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Knowledge Source',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.blue),
            tooltip: 'Add New',
            onPressed: () => _showAddNewEntryDialog(context, controller),
          ),
          Obx(() => IconButton(
                icon: Icon(Icons.edit,
                    color: controller.selectedIds.length == 1
                        ? Colors.blue
                        : Colors.grey),
                tooltip: 'Edit Selected',
                onPressed: controller.selectedIds.length == 1
                    ? () => _showEditAddDialog(context, controller,
                        item: controller.knowledgeSources.firstWhere(
                            (e) => e.contentId == controller.selectedIds.first))
                    : () {
                        controller.hasExactlyOneSelection(
                            message: 'Please select exactly one item to edit.');
                      },
              )),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete Selected',
            onPressed: () {
              if (controller.hasSelection()) {
                _showDeleteConfirmationDialog(context, controller);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => controller.fetchKnowledgeSources(),
          ),
        ],
      ),
      body: Obx(() {
        return Stack(
          children: [
            if (controller.knowledgeSources.isEmpty && !controller.isLoading.value)
              const Center(child: Text('No knowledge sources found.'))
            else
              Column(
                children: [
                  // Filter Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: controller.selectedFilterColumn.value,
                            decoration: InputDecoration(
                              labelText: 'Filter By',
                              labelStyle: const TextStyle(fontSize: 14,  overflow: TextOverflow.ellipsis),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: controller.filterColumns.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis,),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              controller.selectedFilterColumn.value = newValue!;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            onChanged: (value) => controller.searchQuery.value = value,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'Search ${controller.selectedFilterColumn.value}',
                              labelStyle: const TextStyle(fontSize: 14),
                              prefixIcon: const Icon(Icons.search, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        child: PaginatedDataTable(
                          header: const Text('Sources List'),
                          columns: const [
                            DataColumn(label: Text('#')),
                            DataColumn(label: Text('Content ID')),
                            DataColumn(label: Text('Document Content')),
                            DataColumn(label: Text('Source File')),
                            DataColumn(label: Text('Category')),
                            DataColumn(label: Text('Create Date')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Role')),
                          ],
                          source: KnowledgeSourceDataSource(
                            controller.filteredKnowledgeSources,
                            context,
                            controller,
                          ),
                          rowsPerPage: 10,
                          showFirstLastButtons: true,
                          columnSpacing: 20,
                          horizontalMargin: 10,
                          showCheckboxColumn: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (controller.isLoading.value)
              Positioned.fill(
                child: Container(
                  color: AppColors.shadowMedium,
                  child: Center(child: LoadingWidget.loader()),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class KnowledgeSourceDataSource extends DataTableSource {
  final List<KnowledgeSourceModel> data;
  final BuildContext context;
  final KnowledgeSourceController controller;

  KnowledgeSourceDataSource(this.data, this.context, this.controller);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final item = data[index];

    return DataRow(
      selected: controller.isSelected(item.contentId ?? ''),
      onSelectChanged: (bool? selected) {
        if (item.contentId != null) {
          controller.toggleSelection(item.contentId!);
          notifyListeners();
        }
      },
      cells: [
        DataCell(Text('${index + 1}')),
        DataCell(
          Text(item.contentId?.substring(0, 8) ?? 'N/A'),
          onDoubleTap: () => _showDetailsDialog(item.contentId ?? 'N/A'),
        ),
        DataCell(
          SizedBox(
            width: 200, // Reduced width for document content
            child: Text(
              item.documentContent ?? 'N/A',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          onDoubleTap: () => _showDetailsDialog(item.documentContent ?? 'N/A'),
        ),
        DataCell(
          Text(item.sourceFile ?? 'N/A'),
          onDoubleTap: () => _showDetailsDialog(item.sourceFile ?? 'N/A'),
        ),
        DataCell(
          Text(item.category ?? 'N/A'),
          onDoubleTap: () => _showDetailsDialog(item.category ?? 'N/A'),
        ),
        DataCell(
          Text(item.createDate ?? 'N/A'),
          onDoubleTap: () => _showDetailsDialog(item.createDate ?? 'N/A'),
        ),
        DataCell(
          Text(item.status ?? 'N/A'),
          onDoubleTap: () => _showDetailsDialog(item.status ?? 'N/A'),
        ),
        DataCell(
          Text(item.role ?? 'N/A'),
          onDoubleTap: () => _showDetailsDialog(item.role ?? 'N/A'),
        ),
      ],
    );
  }

  void _showDetailsDialog(String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cell Details'),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => controller.selectedIds.length;
}

extension KnowledgeSourceViewExtension on KnowledgeSourceView {
  void _showDeleteConfirmationDialog(
      BuildContext context, KnowledgeSourceController controller) {
    final selectedItems = controller.knowledgeSources
        .where((item) => controller.selectedIds.contains(item.contentId))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: EdgeInsets.zero,
        title: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Confirm Delete',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFA39E)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.orange, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'You are about to delete ',
                          children: [
                            TextSpan(
                              text: '${selectedItems.length}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                                text: ' records. This cannot be undone.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: selectedItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = selectedItems[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'ID: ${item.contentId ?? "N/A"}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475467),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.sourceFile ?? 'N/A',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Cancel', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  controller.performDelete();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD92D20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Delete ${selectedItems.length} records',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditAddDialog(
      BuildContext context, KnowledgeSourceController controller,
      {KnowledgeSourceModel? item}) {
    final isEdit = item != null;
    final _formKey = GlobalKey<FormState>();
    final contentController =
        TextEditingController(text: item?.documentContent ?? '');
    final selectedCategory = (item?.category ?? controller.categories.first).obs;
    final selectedStatus = (item?.status ?? controller.statuses.first).obs;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: EdgeInsets.zero,
        title: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Record' : 'Add Record',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isEdit) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(text: TextSpan(children: [
                            const TextSpan(text: "Content ID: ", style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                            TextSpan(text: '${item.contentId}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          ]),),
                          const SizedBox(height: 4),
                          RichText(text: TextSpan(children: [
                            const TextSpan(text: "Source File: ", style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                            TextSpan(text: '${item.sourceFile}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          ]),),
                          const SizedBox(height: 4),
                          RichText(text: TextSpan(children: [
                            const TextSpan(text: "Created: ", style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                            TextSpan(text: '${item.createDate}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          ]),),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text('Document Content',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF344054))),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: contentController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: "Type or paste your content here...",
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    style: const TextStyle(fontSize: 12),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Content is required' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Category',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF344054))),
                  const SizedBox(height: 6),
                  Obx(() => DropdownButtonFormField<String>(
                        value: selectedCategory.value,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: controller.categories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (newValue) => selectedCategory.value = newValue!,
                        validator: (value) => value == null || value.isEmpty ? 'Category is required' : null,
                      )),
                  const SizedBox(height: 16),
                  const Text('Status',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF344054))),
                  const SizedBox(height: 6),
                  Obx(() => DropdownButtonFormField<String>(
                        value: selectedStatus.value,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: controller.statuses.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (newValue) => selectedStatus.value = newValue!,
                        validator: (value) => value == null || value.isEmpty ? 'Status is required' : null,
                      )),
                ],
              ),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF344054), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newItem = KnowledgeSourceModel(
                      contentId: isEdit ? item.contentId : 'NEW-${DateTime.now().millisecondsSinceEpoch}',
                      documentContent: contentController.text,
                      category: selectedCategory.value,
                      status: selectedStatus.value,
                      sourceFile: isEdit ? item.sourceFile : 'Manual Entry',
                      createDate: isEdit ? item.createDate : DateTime.now().toString(),
                      role: isEdit ? item.role : 'Admin',
                    );
                    if (isEdit) {
                      controller.updateKnowledgeSource(newItem);
                    } else {
                      controller.addKnowledgeSource(newItem);
                    }
                    controller.clearSelection();
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D2939),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  isEdit ? 'Save Changes' : 'Add Source',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  void _showAddNewEntryDialog(
      BuildContext context, KnowledgeSourceController controller) {
    controller.resetAddForm();
    final _formKey = GlobalKey<FormState>();
    final tocController = TextEditingController();
    final plainTextController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: EdgeInsets.zero,
        title: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add New Entry',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Obx(() => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Input Type',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF344054))),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: controller.selectedInputType.value,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: controller.inputTypes
                            .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (val) => controller.selectedInputType.value = val!,
                      ),
                      const SizedBox(height: 16),
                      if (controller.selectedInputType.value == 'File') ...[
                        const Text('Upload Files (max 10 MB each)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF667085))),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                              allowMultiple: true,
                              type: FileType.custom,
                              allowedExtensions: ['txt', 'pdf', 'docx', 'xlsx', 'xls', 'csv', 'pptx', 'html'],
                            );
                            if (result != null) {
                              for (var file in result.files) {
                                if (file.size > 10 * 1024 * 1024) {
                                  Get.snackbar('Warning', 'File ${file.name} exceeds 10MB limit.',
                                      backgroundColor: Colors.orange, colorText: Colors.white);
                                } else {
                                  controller.uploadedFiles.add(file);
                                }
                              }
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFFF9FAFB),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.folder_open, color: Colors.orange, size: 36),
                                const SizedBox(height: 12),
                                const Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(text: 'Drag & drop files here or ', style: TextStyle(fontSize: 13)),
                                      TextSpan(
                                          text: 'click to select',
                                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text('You can select multiple files at once',
                                    style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                        if (controller.uploadedFiles.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 12),
                            child: Text('Please upload at least one file',
                                style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
                          ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.uploadedFiles.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final file = controller.uploadedFiles[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.description_outlined, size: 18, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(file.name, style: const TextStyle(fontSize: 12))),
                                  Text('${(file.size / 1024).toStringAsFixed(0)} KB',
                                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 16, color: Colors.red),
                                    onPressed: () => controller.uploadedFiles.removeAt(index),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        if (controller.uploadedFiles.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text('File Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            hint: const Text('Select category', style: TextStyle(fontSize: 13)),
                            value:
                                controller.selectedAddCategory.value.isEmpty ? null : controller.selectedAddCategory.value,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: controller.categories
                                .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                                .toList(),
                            onChanged: (val) => controller.selectedAddCategory.value = val!,
                            validator: (value) => value == null || value.isEmpty ? 'Category is required' : null,
                          ),
                          const SizedBox(height: 16),
                          const Text('Is Table of Contents available?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Row(
                            children: [
                              Radio<String>(
                                value: 'Yes',
                                groupValue: controller.isTOCAvailable.value,
                                onChanged: (v) => controller.isTOCAvailable.value = v!,
                              ),
                              const Text('Yes', style: TextStyle(fontSize: 13)),
                              Radio<String>(
                                value: 'No',
                                groupValue: controller.isTOCAvailable.value,
                                onChanged: (v) => controller.isTOCAvailable.value = v!,
                              ),
                              const Text('No', style: TextStyle(fontSize: 13)),
                              Radio<String>(
                                value: 'NA',
                                groupValue: controller.isTOCAvailable.value,
                                onChanged: (v) => controller.isTOCAvailable.value = v!,
                              ),
                              const Text('NA', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                          if (controller.isTOCAvailable.value == 'No') ...[
                            const SizedBox(height: 8),
                            const Text('Enter Table of Contents / Main Headings',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: tocController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: "1. Introduction\n2. Scope\n3. Process Overview...",
                                hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                              style: const TextStyle(fontSize: 12),
                              onChanged: (v) => controller.tocHeadings.value = v,
                              validator: (value) => (value == null || value.trim().isEmpty) ? 'Headings are required' : null,
                            ),
                          ],
                        ],
                      ] else ...[
                        const Text('Document Content', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: plainTextController,
                          maxLines: 8,
                          decoration: InputDecoration(
                            hintText: "Type or paste your content here...",
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          style: const TextStyle(fontSize: 12),
                          onChanged: (v) => controller.plainTextContent.value = v,
                          validator: (value) => (value == null || value.trim().isEmpty) ? 'Content is required' : null,
                        ),
                        const SizedBox(height: 16),
                        const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          hint: const Text('Select category', style: TextStyle(fontSize: 13)),
                          value:
                              controller.selectedAddCategory.value.isEmpty ? null : controller.selectedAddCategory.value,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: controller.categories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (val) => controller.selectedAddCategory.value = val!,
                          validator: (value) => value == null || value.isEmpty ? 'Category is required' : null,
                        ),
                      ],
                    ],
                  )),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF344054), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (controller.selectedInputType.value == 'File') {
                      if (controller.uploadedFiles.isEmpty) return;

                      // Close the Add Dialog first
                      Get.back();

                      // Start the analysis workflow
                      controller.clearAnalysis();
                      
                      for (int i = 0; i < controller.uploadedFiles.length; i++) {
                        controller.currentProcessingIndex.value = i;
                        final file = controller.uploadedFiles[i];
                        
                        // Show loader before analysis
                        LoadingWidget.showLoader(context);
                        try {
                          await controller.analyzeFile(file);
                        } finally {
                          if (context.mounted) {
                            LoadingWidget.closeLoader(context);
                          }
                        }
                        
                        if (!context.mounted) return;
                        
                        if (controller.analysisResult.value != null) {
                          bool? result = await _showSimilarityAnalysisDialog(context, controller);
                          if (result != true) {
                            // If user cancelled, stop processing further files
                            break;
                          }
                        }
                      }
                      
                      Get.snackbar('Processing Finished', 'All files have been analyzed.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF1D2939),
                          colorText: Colors.white);
                    } else {
                      // Success handling for Plain Text
                      final newItem = KnowledgeSourceModel(
                        contentId: 'TEXT-${DateTime.now().millisecondsSinceEpoch}',
                        documentContent: controller.plainTextContent.value,
                        category: controller.selectedAddCategory.value,
                        status: 'COMPLETED',
                        sourceFile: 'Plain Text Entry',
                        createDate: DateTime.now().toString(),
                        role: 'Admin',
                      );
                      controller.addKnowledgeSource(newItem);
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D2939),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool?> _showSimilarityAnalysisDialog(
      BuildContext context, KnowledgeSourceController controller) {
    return Get.dialog<bool>(
      barrierDismissible: false,
      Obx(() {
        if (controller.analysisResult.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final result = controller.analysisResult.value!;
        final comparison = result['comparison_result'] ?? {};
        final score = (comparison['final_score'] ?? 0.0);
        final matchedFiles = (comparison['matched_files'] as List?) ?? [];
        final differences = (comparison['differences'] as List?) ?? [];

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(24),
          titlePadding: EdgeInsets.zero,
          content: SizedBox(
            width: 750,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STEP ${controller.currentProcessingIndex.value + 1} OF ${controller.uploadedFiles.length} — SIMILARITY CHECK',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF667085)),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Document Similarity Analysis',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'File ${controller.currentProcessingIndex.value + 1} of ${controller.uploadedFiles.length}: ${result['file_name'] ?? 'Unknown'}',
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF667085)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF667085)),
                        onPressed: () => Get.back(result: null),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Score Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE4E7EC)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('FINAL SIMILARITY SCORE',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF667085))),
                              const SizedBox(height: 12),
                              Text(
                                comparison['similarity_message'] ?? 'Calculating similarity results...',
                                style: const TextStyle(
                                    fontSize: 15, color: Color(0xFF344054), height: 1.4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Final score',
                                style: TextStyle(
                                    fontSize: 11, color: Color(0xFF667085))),
                            const SizedBox(height: 4),
                            Text('${double.tryParse(score.toString())?.toStringAsFixed(2) ?? '0.00'}%',
                                style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2970FF))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Matched Documents Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE4E7EC)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('MATCHED EXISTING DOCUMENTS',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF667085))),
                        const SizedBox(height: 16),
                        if (matchedFiles.isEmpty)
                          const Text('No existing documents matched.',
                              style: TextStyle(fontSize: 14, color: Color(0xFF667085)))
                        else
                          ...matchedFiles.map((f) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.file_present_outlined, size: 16, color: Color(0xFF2970FF)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text('Matched file: ${f['source_file'] ?? 'Untitled'}',
                                      style: const TextStyle(
                                          fontSize: 14, color: Color(0xFF344054), fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                          )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  const Text('DIFFERENCES FROM EXISTING DOCUMENTS',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667085))),
                  const SizedBox(height: 12),
                  
                  // Diff Section
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 350),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE4E7EC)),
                    ),
                    child: differences.isEmpty 
                      ? const Center(child: Text('No differences detected.', style: TextStyle(color: Color(0xFF667085))))
                      : Scrollbar(
                          thumbVisibility: true,
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(12),
                            itemCount: differences.length,
                            itemBuilder: (context, index) {
                              final diff = differences[index].toString();
                              Color textColor = const Color(0xFF344054);
                              
                              if (diff.startsWith('+')) {
                                textColor = const Color(0xFF027A48); // Dark green
                              } else if (diff.startsWith('-')) {
                                textColor = const Color(0xFFB42318); // Dark red
                              }
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  diff,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'monospace',
                                    fontWeight: (diff.startsWith('+') || diff.startsWith('-')) 
                                        ? FontWeight.w500 : FontWeight.normal,
                                    color: textColor,
                                    height: 1.5,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  ),
                  const SizedBox(height: 36),
                  
                  // Action Buttons
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => Get.back(result: null),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          side: const BorderSide(color: Color(0xFFD0D5DD)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cancel all', 
                          style: TextStyle(color: Color(0xFF344054), fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          foregroundColor: Colors.orange.shade800,
                          backgroundColor: Colors.orange.shade50,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Skip this file', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Logic for "Train this file"
                          Get.back(result: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2970FF),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text('Train this file ➔', 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
