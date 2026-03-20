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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3F2),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(Icons.delete_outline,
                          color: Color(0xFFD92D20), size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Confirm Delete',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF101828),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF667085), size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEAECF0)),
              
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
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
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFD92D20), size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: 'You are about to delete ',
                                  style: const TextStyle(fontSize: 14, color: Color(0xFFB42318)),
                                  children: [
                                    TextSpan(
                                      text: '${selectedItems.length}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(text: ' records. This action cannot be undone.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFEAECF0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                                border: Border.all(color: const Color(0xFFF2F4F7)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ID: ${item.contentId ?? "N/A"}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF344054), fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.sourceFile ?? 'N/A',
                                    style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Actions
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFD0D5DD)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Color(0xFF344054), fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          controller.performDelete();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD92D20),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Delete',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.95,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add New Entry',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1D2939))),
                    IconButton(
                      icon: const Icon(Icons.close, size: 22, color: Color(0xFF667085)),
                      onPressed: () => Navigator.pop(dialogContext),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Obx(() => Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Input Method',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF344054))),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: controller.selectedInputType.value,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2970FF), width: 1.5)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              items: controller.inputTypes
                                  .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 14, color: Color(0xFF1D2939)))))
                                  .toList(),
                              onChanged: (val) => controller.selectedInputType.value = val!,
                            ),
                            const SizedBox(height: 20),
                            
                            if (controller.selectedInputType.value == 'File') ...[
                              const Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(text: 'Upload Files ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF344054))),
                                    TextSpan(text: '(max 10 MB each)', style: TextStyle(fontSize: 14, color: Color(0xFF98A2B3))),
                                  ]
                                )
                              ),
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
                                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFEAECF0), width: 1.5),
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.folder, color: Color(0xFFFFCA28), size: 40),
                                      const SizedBox(height: 12),
                                      const Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(text: 'Drag & drop files here or ', style: TextStyle(fontSize: 14, color: Color(0xFF475467))),
                                            TextSpan(
                                                text: 'click to select',
                                                style: TextStyle(color: Color(0xFF2970FF), fontSize: 14, decoration: TextDecoration.underline)),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text('Supported: .txt, .pdf, .docx, .xlsx, .xls, .csv, .pptx, .html - Max 10 MB per file',
                                          style: TextStyle(fontSize: 12, color: Color(0xFF98A2B3)),
                                          textAlign: TextAlign.center),
                                    ],
                                  ),
                                ),
                              ),
                              if (controller.uploadedFiles.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.uploadedFiles.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final file = controller.uploadedFiles[index];
                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: const Color(0xFFEAECF0)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.insert_drive_file_outlined, size: 20, color: Color(0xFF2970FF)),
                                          const SizedBox(width: 12),
                                          Expanded(child: Text(file.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF344054)), overflow: TextOverflow.ellipsis)),
                                          Text('${(file.size / 1024).toStringAsFixed(0)} KB',
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF667085))),
                                          const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () => controller.uploadedFiles.removeAt(index),
                                              child: const Icon(Icons.delete_outline, size: 20, color: Color(0xFF667085)),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                                const Text('Category',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF344054))),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  hint: const Text('Select file category', style: TextStyle(fontSize: 14)),
                                  value: controller.selectedAddCategory.value.isEmpty ? null : controller.selectedAddCategory.value,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  items: controller.categories
                                      .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14))))
                                      .toList(),
                                  onChanged: (val) => controller.selectedAddCategory.value = val!,
                                  validator: (value) => value == null || value.isEmpty ? 'Category is required' : null,
                                ),
                                const SizedBox(height: 24),
                                const Text('Table of Contents available?',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF344054))),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    children: ['Yes', 'No', 'NA'].map((option) {
                                      final isSelected = controller.isTOCAvailable.value == option;
                                      return Expanded(
                                        child: GestureDetector(
                                          onTap: () => controller.isTOCAvailable.value = option,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            decoration: BoxDecoration(
                                              color: isSelected ? Colors.white : Colors.transparent,
                                              borderRadius: BorderRadius.circular(8),
                                              boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
                                            ),
                                            child: Center(
                                              child: Text(option, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? const Color(0xFF1D2939) : const Color(0xFF667085))),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                if (controller.isTOCAvailable.value == 'No') ...[
                                  const SizedBox(height: 20),
                                  const Text('Main Headings / Sections',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF344054))),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: tocController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: "e.g. 1. Intro, 2. Process, 3. Summary",
                                      hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 13),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEAECF0))),
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                    style: const TextStyle(fontSize: 13),
                                    onChanged: (v) => controller.tocHeadings.value = v,
                                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Required when TOC is not available' : null,
                                  ),
                                ],
                              ],
                            ] else ...[
                              const Text('File Name',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF344054))),
                              const SizedBox(height: 8),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: "Enter a file name (e.g., asdf.text)",
                                  hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 13),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2970FF), width: 1.5)),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                style: const TextStyle(fontSize: 13, height: 1.5),
                                onChanged: (v) => controller.textFileName.value = v,
                                validator: (value) => (value == null || value.trim().isEmpty) ? 'File name is required' : null,
                              ),
                              const SizedBox(height: 20),
                              const Text('Content Details',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF344054))),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: plainTextController,
                                maxLines: 6,
                                decoration: InputDecoration(
                                  hintText: "Enter or paste your text content here...",
                                  hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 13),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2970FF), width: 1.5)),
                                  contentPadding: const EdgeInsets.all(16),
                                  counterText: '${controller.plainTextContent.value.length} / 500',
                                  counterStyle: const TextStyle(fontSize: 11, color: Color(0xFF667085)),
                                ),
                                style: const TextStyle(fontSize: 13, height: 1.5),
                                onChanged: (v) => controller.plainTextContent.value = v,
                                validator: (value) => (value == null || value.trim().length < 500) ? 'Text content must be 500 characters or more' : null,
                              ),
                              const SizedBox(height: 20),
                              const Text('Category',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF344054))),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                hint: const Text('Select file category', style: TextStyle(fontSize: 14)),
                                value: controller.selectedAddCategory.value.isEmpty ? null : controller.selectedAddCategory.value,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                items: controller.categories
                                    .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14))))
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
              
              // Actions
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (controller.selectedInputType.value == 'File') {
                            if (controller.uploadedFiles.isEmpty) {
                              Get.snackbar('Warning', 'Please select at least one document to upload.', backgroundColor: Colors.orange, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                              return;
                            }
                            Get.back();
                            await Future.delayed(const Duration(milliseconds: 300));
                            controller.clearAnalysis();
                            for (int i = 0; i < controller.uploadedFiles.length; i++) {
                              controller.currentProcessingIndex.value = i;
                              final file = controller.uploadedFiles[i];
                              try {
                                await controller.analyzeFile(file);
                              } catch (e) {
                                debugPrint('Analysis failed: $e');
                              }
                              await Future.delayed(const Duration(milliseconds: 500));
                              if (!context.mounted) return;
                              if (controller.analysisResult.value != null) {
                                int step = 1; 
                                bool skipFile = false;
                                while (step >= 1 && step <= 3) {
                                  if (step == 1) {
                                    bool? res = await _showSimilarityAnalysisDialog(context, controller);
                                    if (res == null) { i = controller.uploadedFiles.length; step = 10; }
                                    else if (res == false) { skipFile = true; step = 10; }
                                    else {
                                      try { await controller.trainPreviewQuestions(file); } catch (e) {}
                                      if (controller.previewResult.value != null) step = 2; else step = 10;
                                    }
                                  } else if (step == 2) {
                                    bool? res = await _showFinanceCheckDialog(context, controller);
                                    if (res == null) step = 1;
                                    else if (res == false) { skipFile = true; step = 10; }
                                    else step = 3;
                                  } else if (step == 3) {
                                    bool? res = await _showQAPreviewDialog(context, controller);
                                    if (res == null) step = 2;
                                    else if (res == false) { skipFile = true; step = 10; }
                                    else {
                                      try { await controller.addDocument(file); } catch (e) {}
                                      step = 10;
                                    }
                                  }
                                }
                                if (skipFile) continue;
                              }
                            }
                          } else {
                            // Plain Text Workflow
                            Get.back(); // Close Add Dialog
                            await Future.delayed(const Duration(milliseconds: 300));
                            
                            final result = await controller.addPlainText();
                            if (result != null) {
                              final newItem = KnowledgeSourceModel(
                                contentId: 'TEXT-${DateTime.now().millisecondsSinceEpoch}',
                                documentContent: controller.plainTextContent.value,
                                category: controller.selectedAddCategory.value,
                                status: 'COMPLETED',
                                sourceFile: controller.textFileName.value.isNotEmpty ? controller.textFileName.value : 'Plain Text Entry',
                                createDate: DateTime.now().toString(),
                                role: 'Rahul',
                              );
                              controller.addKnowledgeSource(newItem);
                              
                              if (context.mounted) {
                                _showTrainingStatusDialog(context, result['Content_File'] ?? controller.textFileName.value, result['message'] ?? 'Training completed successfully.');
                              }
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2970FF),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Submit Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 44), foregroundColor: const Color(0xFF667085)),
                      child: const Text('Cancel Request', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showSimilarityAnalysisDialog(
      BuildContext context, KnowledgeSourceController controller) {
    return Get.dialog<bool>(
      barrierDismissible: false,
      Obx(() {
        final analysis = controller.analysisResult.value;
        if (analysis == null) {
          // This check is kept as the dialog might be shown before analysisResult is fully populated,
          // or if there's an error and it remains null.
          return const Center(child: CircularProgressIndicator());
        }
        final result = analysis; // Use 'analysis' instead of 'result'
        final comparison = result['comparison_result'] ?? {};
        final score = (comparison['final_score'] ?? 0.0);
        final matchedFiles = (comparison['matched_files'] as List?) ?? [];
        final differences = (comparison['differences'] as List?) ?? [];

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.95,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Progress Indicator and Close
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STEP ${controller.currentProcessingIndex.value + 1} OF 3',
                          style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Similarity Analysis',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 18, color: Color(0xFF667085)),
                      ),
                      onPressed: () => Get.back(result: null),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // File Name Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.description_outlined, size: 14, color: Colors.blue),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          result['file_name'] ?? 'Unknown File',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Score Summary Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${double.tryParse(score.toString())?.toStringAsFixed(1) ?? '0.0'}%',
                                style: const TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2970FF),
                                    letterSpacing: -1),
                              ),
                              const Text(
                                'Similarity Score',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF667085)),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                comparison['similarity_message'] ?? 'Document check complete.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF344054), height: 1.4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Matched Docs
                        const Text('MATCHED DOCUMENTS',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                                color: Color(0xFF667085))),
                        const SizedBox(height: 12),
                        if (matchedFiles.isEmpty)
                          const Text('No direct matches found.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF667085)))
                        else
                          ...matchedFiles.map((f) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE4E7EC)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.link, size: 16, color: Color(0xFF2970FF)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(f['source_file'] ?? 'Untitled',
                                      style: const TextStyle(
                                          fontSize: 13, color: Color(0xFF344054), fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                          )),
                        
                        const SizedBox(height: 24),
                        
                        const Text('CONTENT DIFFERENCES',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                                color: Color(0xFF667085))),
                        const SizedBox(height: 12),
                        
                        // Diff Section - Optimized for Mobile
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF101828), // Dark theme for diffs looks premium
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: differences.isEmpty 
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(child: Text('Identical content.', style: TextStyle(color: Colors.grey))),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...differences.map((diffItem) {
                                      final diff = diffItem.toString();
                                      Color? bgColor;
                                      Color textColor = Colors.grey.shade300;
                                      
                                      if (diff.startsWith('+')) {
                                        textColor = const Color(0xFF6CE9A6); // Green
                                        bgColor = const Color(0xFF027A48).withOpacity(0.2);
                                      } else if (diff.startsWith('-')) {
                                        textColor = const Color(0xFFFDA29B); // Red
                                        bgColor = const Color(0xFFB42318).withOpacity(0.2);
                                      }
                                      
                                      return Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        child: Text(
                                          diff,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontFamily: 'monospace',
                                            color: textColor,
                                            height: 1.5,
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Mobile Action Buttons - Grid or Column style
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Logic for "Train this file"
                        Get.back(result: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2970FF),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Train this file ➔', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(result: null),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFD0D5DD)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Cancel all', 
                              style: TextStyle(color: Color(0xFF344054), fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextButton(
                            onPressed: () => Get.back(result: false), // result: false = Skip
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: Colors.orange.shade800,
                              backgroundColor: Colors.orange.shade50,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Skip file', 
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
  Future<bool?> _showFinanceCheckDialog(
      BuildContext context, KnowledgeSourceController controller) {
    return Get.dialog<bool>(
      barrierDismissible: false,
      Obx(() {
        if (controller.previewResult.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final result = controller.previewResult.value!;
        final finance = result['finance_detection'] ?? {};
        final isFinance = finance['is_finance_related'] ?? false;
        final isText = controller.selectedInputType.value == 'Plain Text';
        final fileName = isText ? 'Manual Text Entry' : (controller.uploadedFiles.isNotEmpty ? controller.uploadedFiles[controller.currentProcessingIndex.value].name : 'Unknown File');

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.95,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STEP 2 OF 3 — FINANCE CHECK',
                          style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Finance-related content',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Get.back(result: null),
                    ),
                  ],
                ),
                if (!isText) ...[
                  const SizedBox(height: 4),
                  Text(
                    'File: $fileName',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isFinance ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isFinance ? Colors.red.shade100 : Colors.green.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isFinance ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                        color: isFinance ? Colors.red : Colors.green,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isFinance ? 'Finance-related content detected' : 'No finance-related content detected',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isFinance ? Colors.red.shade900 : Colors.green.shade900,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isFinance 
                                ? 'This document contains financial information. Please review before proceeding.'
                                : 'This document looks safe to proceed with training.',
                              style: TextStyle(
                                color: isFinance ? Colors.red.shade700 : Colors.green.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (isFinance && finance['finance_data'] != null && finance['finance_data'].toString().isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Detected Financial Data:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      finance['finance_data'].toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(result: false), // result: false = skip/cancel
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFD0D5DD)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel (skip this file)', 
                          style: TextStyle(color: Color(0xFF344054), fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2970FF),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text('Continue to Q&A →', 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<bool?> _showQAPreviewDialog(
      BuildContext context, KnowledgeSourceController controller) {
    return Get.dialog<bool>(
      barrierDismissible: false,
      Obx(() {
        final result = controller.previewResult.value;
        if (result == null) return const SizedBox.shrink();

        final qaPairs = (result['qa_pairs'] as List?) ?? [];
        final isText = controller.selectedInputType.value == 'Plain Text';
        final fileName = isText ? 'Manual Text Entry' : (controller.uploadedFiles.isNotEmpty ? controller.uploadedFiles[controller.currentProcessingIndex.value].name : 'Unknown File');

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.95,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STEP 3 OF 3 — SAMPLE Q&A',
                          style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Document preview Q&A',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Get.back(result: null),
                    ),
                  ],
                ),
                if (!isText) ...[
                  const SizedBox(height: 4),
                  Text(
                    'File ${controller.currentProcessingIndex.value + 1} of ${controller.uploadedFiles.length}: $fileName',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
                const SizedBox(height: 20),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...qaPairs.map((pair) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade50),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50.withOpacity(0.3),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Q ', 
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          pair['question'] ?? 'N/A',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.4, color: Color(0xFF1D2939)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('A ', 
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          pair['answer'] ?? 'N/A',
                                          style: TextStyle(fontSize: 12, height: 1.5, color: Colors.grey.shade700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Get.back(result: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2970FF),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Train this document →', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: OutlinedButton(
                            onPressed: () => Get.back(result: false), // result: false = skip file
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFD0D5DD)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Cancel (skip)', 
                              style: TextStyle(color: Color(0xFF344054), fontWeight: FontWeight.w600, fontSize: 11)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: OutlinedButton(
                            onPressed: () => Get.back(result: null), // result: null = back
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFD0D5DD)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Back', 
                              style: TextStyle(color: Color(0xFF344054), fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showTrainingStatusDialog(BuildContext context, String fileName, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Training Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D2939))),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 20, color: Color(0xFF667085)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFEAECF0)),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 13, color: Color(0xFF475467)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD1FADF)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12B76A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fileName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF027A48)), overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          const Text('Training completed successfully.', style: TextStyle(fontSize: 12, color: Color(0xFF027A48))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FADF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Done', style: TextStyle(color: Color(0xFF027A48), fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerRight,
                child: Text('1 / 1 completed', style: TextStyle(fontSize: 12, color: Color(0xFF667085))),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFEAECF0)),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D2939),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
