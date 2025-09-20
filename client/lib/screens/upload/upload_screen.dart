import 'dart:io' show File;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();

  late String requestId;
  String startupName = "";
  String founderName = "";
  String founderEmail = "";

  PlatformFile? checklistFile; // Single file category
  List<PlatformFile> pitchDeckFiles = [];
  List<PlatformFile> emailMessages = [];
  List<PlatformFile> callRecordings = [];
  List<PlatformFile> callTranscripts = [];

  String? summary; // AI-generated summary

  @override
  void initState() {
    super.initState();
    requestId = _generateRequestId();
  }

  String _generateRequestId() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  Future<MultipartFile> _buildMultipartFile(
      PlatformFile pickedFile, String fieldName) async {
    if (kIsWeb) {
      Uint8List fileBytes = pickedFile.bytes!;
      return MultipartFile.fromBytes(fileBytes, filename: pickedFile.name);
    } else {
      File file = File(pickedFile.path!);
      return await MultipartFile.fromFile(
        file.path,
        filename: file.path.split("/").last,
      );
    }
  }

  Future<void> addFilesToFormData(
      String fieldPrefix, List<PlatformFile> files, FormData formData) async {
    for (int i = 0; i < files.length; i++) {
      final multipartFile = MultipartFile.fromBytes(
        files[i].bytes ?? Uint8List(0),
        filename: files[i].name,
      );
      formData.files.add(MapEntry("$fieldPrefix$i", multipartFile));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (checklistFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Checklist is required.")));
      return;
    }

    _formKey.currentState!.save();

    try {
      final dio = Dio();
      FormData formData = FormData();

      formData.fields.addAll([
        MapEntry("request_id", requestId),
        MapEntry("founder_name", founderName),
        MapEntry("founder_email", founderEmail),
        MapEntry("startup_name", startupName),
      ]);

      if (checklistFile != null) {
        formData.files.add(
          MapEntry(
            "founderChecklist",
            await _buildMultipartFile(checklistFile!, "founderChecklist"),
          ),
        );
      }

      for (int i = 0; i < pitchDeckFiles.length; i++) {
        formData.files.add(
          MapEntry(
            "pitchDeck$i",
            await _buildMultipartFile(pitchDeckFiles[i], "pitchDeck$i"),
          ),
        );
      }

      await addFilesToFormData("emailMessages", emailMessages, formData);
      await addFilesToFormData("callRecordings", callRecordings, formData);
      await addFilesToFormData("callTranscripts", callTranscripts, formData);

      final response = await dio.post(
        "http://127.0.0.1:8000/analyze-documents/",
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      setState(() {
        summary = response.data['summary'];
        requestId = _generateRequestId();
        startupName = "";
        founderName = "";
        founderEmail = "";
        checklistFile = null;
        pitchDeckFiles = [];
        emailMessages = [];
        callRecordings = [];
        callTranscripts = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Documents submitted successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Submission failed: $e")));
    }
  }

  void _openUploadDialog({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> allowedExtensions,
    required List<PlatformFile> initialFiles,
    required bool singleFile,
    required Function(List<PlatformFile>) onFilesChanged,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        return UploadDialog(
          title: title,
          icon: icon,
          color: color,
          allowedExtensions: allowedExtensions,
          initialFiles: initialFiles,
          singleFile: singleFile,
          onFilesChanged: onFilesChanged,
        );
      },
    );
  }

  Widget _buildTextField(String label, Function(String?) onSaved,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
      onSaved: onSaved,
      keyboardType: keyboardType,
      validator: (v) {
        if (v == null || v.isEmpty) return "Required";
        if (label == "Founder Email ID" && !v.contains("@")) return "Invalid email";
        return null;
      },
    );
  }

  Widget _fileChip(
          PlatformFile file, IconData icon, Color color, VoidCallback onDelete) =>
      Chip(
        avatar: CircleAvatar(
            backgroundColor: color, child: Icon(icon, color: Colors.white, size: 16)),
        label: Text(file.name, overflow: TextOverflow.ellipsis),
        deleteIcon: Icon(Icons.close, size: 18),
        onDeleted: onDelete,
      );

  Widget _uploadSection(
    String label,
    IconData icon,
    Color color,
    List<PlatformFile> files,
    bool singleFile,
    List<String> allowedExtensions,
    Function(List<PlatformFile>) onFilesChanged,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
      margin: EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(icon, color: color, size: 38),
              title: Text(label,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              trailing: ElevatedButton.icon(
                icon: Icon(Icons.upload_file, color: Colors.white),
                label: Text("Upload", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  backgroundColor: color,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () => _openUploadDialog(
                  title: label,
                  icon: icon,
                  color: color,
                  allowedExtensions: allowedExtensions,
                  initialFiles: files,
                  singleFile: singleFile,
                  onFilesChanged: (newFiles) {
                    setState(() {
                      final combined = List<PlatformFile>.from(files);
                      for (var newFile in newFiles) {
                        if (!combined.any((f) => f.name == newFile.name)) {
                          combined.add(newFile);
                        }
                      }
                      onFilesChanged(combined);
                    });
                  },
                ),
              ),
            ),

            if (files.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  "No files uploaded yet.",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: files
                      .map((f) => _fileChip(f, icon, color, () {
                            setState(() {
                              var updatedList = files.where((file) => file != f).toList();
                              onFilesChanged(updatedList);
                            });
                          }))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Evaluation Request Submission"),
        backgroundColor: Colors.blueGrey.shade900,
        elevation: 3,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Request ID: $requestId",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade900,
                      fontSize: 16)),
              SizedBox(height: 24),
              _buildTextField("Startup Name", (v) => startupName = v ?? ""),
              SizedBox(height: 16),
              _buildTextField("Founder Name", (v) => founderName = v ?? ""),
              SizedBox(height: 16),
              _buildTextField("Founder Email ID", (v) => founderEmail = v ?? "",
                  keyboardType: TextInputType.emailAddress),
              SizedBox(height: 32),

              _uploadSection(
                "Upload Checklist (PDF)",
                Icons.picture_as_pdf,
                Colors.redAccent,
                checklistFile != null ? [checklistFile!] : [],
                true,
                ["pdf"],
                (files) {
                  checklistFile = files.isNotEmpty ? files[0] : null;
                },
              ),
              _uploadSection(
                "Upload Pitch Deck (PDF, PPT, PPTX)",
                Icons.slideshow,
                Colors.deepPurple,
                pitchDeckFiles,
                false,
                ["pdf", "ppt", "pptx"],
                (files) {
                  pitchDeckFiles = files;
                },
              ),
              _uploadSection(
                "Upload Email Messages (PDF, EML, TXT)",
                Icons.email,
                Colors.blue,
                emailMessages,
                false,
                ["pdf", "eml", "txt"],
                (files) {
                  emailMessages = files;
                },
              ),
              _uploadSection(
                "Upload Call Recordings (MP3, WAV, MP4, M4A)",
                Icons.record_voice_over,
                Colors.teal,
                callRecordings,
                false,
                ["mp3", "wav", "mp4", "m4a"],
                (files) {
                  callRecordings = files;
                },
              ),
              _uploadSection(
                "Upload Call Transcripts (PDF, DOC, DOCX, TXT)",
                Icons.text_snippet,
                Colors.grey.shade800,
                callTranscripts,
                false,
                ["pdf", "doc", "docx", "txt"],
                (files) {
                  callTranscripts = files;
                },
              ),

              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 7,
                ),
                child: Text(
                  "Submit Request",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              SizedBox(height: 32),

              if (summary != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AI-generated Summary",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 1),
                                blurRadius: 6)
                          ]),
                      padding: EdgeInsets.all(12),
                      child: Text(summary!),
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class UploadDialog extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> allowedExtensions;
  final List<PlatformFile> initialFiles;
  final bool singleFile;
  final Function(List<PlatformFile>) onFilesChanged;

  const UploadDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.allowedExtensions,
    required this.initialFiles,
    required this.singleFile,
    required this.onFilesChanged,
  });

  @override
  State<UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<UploadDialog> {
  late List<PlatformFile> selectedFiles;

  @override
  void initState() {
    super.initState();
    selectedFiles = List.from(widget.initialFiles);
  }

  Future<void> _pickLocalFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: widget.allowedExtensions,
      allowMultiple: !widget.singleFile,
      withData: kIsWeb,
    );
    if (result != null) {
      setState(() {
        if (widget.singleFile) {
          selectedFiles = [result.files.first];
        } else {
          for (final newFile in result.files) {
            if (!selectedFiles.any((f) => f.name == newFile.name)) {
              selectedFiles.add(newFile);
            }
          }
        }
      });
    }
  }

  void _removeFile(PlatformFile file) {
    setState(() {
      selectedFiles.remove(file);
    });
  }

  void _browseOnlineDocs() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Browse Online Documents"),
        content: Text("Feature to browse online docs can be implemented here."),
        actions: [
          TextButton(
            child: Text("Close"),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  void _onUploadPressed() {
    widget.onFilesChanged(selectedFiles);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(widget.icon, color: widget.color),
          SizedBox(width: 10),
          Expanded(
            child: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.folder_open),
                  label: Text("Browse Local Files"),
                  onPressed: _pickLocalFiles,
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.cloud),
                  label: Text("Browse Online Docs"),
                  onPressed: _browseOnlineDocs,
                ),
              ],
            ),
            Divider(),
            if (selectedFiles.isEmpty)
              Expanded(
                child: Center(
                  child: Text("No files selected."),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = selectedFiles[index];
                    return ListTile(
                      leading: Icon(widget.icon, color: widget.color),
                      title: Text(file.name),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _removeFile(file),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(), child: Text("Cancel")),
        ElevatedButton(
          onPressed: _onUploadPressed,
          style: ElevatedButton.styleFrom(backgroundColor: widget.color),
          child: Text("Upload Selected"),
        ),
      ],
    );
  }
}
