import 'dart:io' show File, Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

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

  PlatformFile? checklistFile;
  PlatformFile? pitchDeckFile;
  List<PlatformFile> supportingDocs = [];
  List<PlatformFile> emailMessages = [];
  List<PlatformFile> callRecordings = [];
  List<PlatformFile> callTranscripts = [];

  String? summary; // AI-generated summary

  @override
  void initState() {
    super.initState();
    requestId = _generateRequestId();
  }

  String _generateRequestId() {
    // Simple UUID generator
    return DateTime.now().millisecondsSinceEpoch.toString();
    // return Uuid().v4();
  }

  Future<void> _pickFile(
    Function(PlatformFile) onPicked, {
    List<String>? allowedExtensions,
    bool allowMultiple = false,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
      withData: kIsWeb, // For web, we need the bytes
    );

    if (result != null) {
      if (allowMultiple) {
        setState(() {
          supportingDocs = result.files;
        });
      } else {
        setState(() {
          onPicked(result.files.first);
        });
      }
    }
  }

  Future<void> _pickFiles(
    void Function(List<PlatformFile>) onPicked, {
    required List<String> allowedExtensions,
    bool allowMultiple = false,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
    );
    if (result != null) {
      onPicked(result.files); // ✅ This is a List<PlatformFile>
    }
  }

  // Helper function to create MultipartFile cross-platform
  Future<MultipartFile> _buildMultipartFile(
    PlatformFile pickedFile,
    String fieldName,
  ) async {
    if (kIsWeb) {
      // Web: use bytes
      Uint8List fileBytes = pickedFile.bytes!;
      return MultipartFile.fromBytes(fileBytes, filename: pickedFile.name);
    } else {
      // Mobile/Desktop: use path
      File file = File(pickedFile.path!);
      return await MultipartFile.fromFile(
        file.path,
        filename: file.path.split("/").last,
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (checklistFile == null || pitchDeckFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Checklist and Pitch Deck are required.")),
      );
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
      // Founder Checklist
      if (checklistFile != null) {
        formData.files.add(
          MapEntry(
            "founderChecklist",
            await _buildMultipartFile(
              checklistFile as PlatformFile,
              "founderChecklist",
            ),
          ),
        );
      }

      // Pitch Deck
      if (pitchDeckFile != null) {
        formData.files.add(
          MapEntry(
            "pitchDeck",
            await _buildMultipartFile(
              pitchDeckFile as PlatformFile,
              "pitchDeck",
            ),
          ),
        );
      }

      // Optional Supporting Docs
      if (supportingDocs.isNotEmpty) {
        formData.files.add(
          MapEntry(
            "otherDoc1",
            await _buildMultipartFile(supportingDocs[0], "otherDoc1"),
          ),
        );

        if (supportingDocs.length >= 2) {
          formData.files.add(
            MapEntry(
              "otherDoc2",
              await _buildMultipartFile(supportingDocs[1], "otherDoc2"),
            ),
          );
        }
      }
      print("Submitting form data: ${formData} ");
      final response = await dio.post(
        "http://127.0.0.1:8000/analyze-documents/",
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      setState(() {
        summary = response.data['summary'];
        // Reset form if needed
        requestId = _generateRequestId();
        startupName = "";
        founderName = "";
        founderEmail = "";
        checklistFile = null;
        pitchDeckFile = null;
        supportingDocs = [];
      });
      var responseContent = response.data.toString();
      print("Response from server: $responseContent");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Documents submitted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Submission failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Documents")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "Request ID: $requestId",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Startup Name",
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                    onSaved: (v) => startupName = v!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Founder Name",
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                    onSaved: (v) => founderName = v!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Founder Email ID",
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v!.isEmpty || !v.contains("@") ? "Invalid email" : null,
                    onSaved: (v) => founderEmail = v!,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.picture_as_pdf),
                    title: Text(
                      checklistFile == null
                          ? "Upload Checklist (PDF)"
                          : checklistFile!.name,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.upload),
                      onPressed: () => _pickFile(
                        (file) => checklistFile = file,
                        allowedExtensions: ["pdf"],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.slideshow),
                    title: Text(
                      pitchDeckFile == null
                          ? "Upload Pitch Deck (PDF, PPT, PPTX)"
                          : pitchDeckFile!.name,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.upload),
                      onPressed: () => _pickFile(
                        (file) => pitchDeckFile = file,
                        allowedExtensions: ["pdf", "ppt", "pptx"],
                      ),
                    ),
                  ),
                  // 📧 Email Messages
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(
                      emailMessages.isEmpty
                          ? "Upload Email Messages"
                          : "${emailMessages.length} file(s) selected",
                    ),
                    subtitle: const Text(
                      "Attach relevant emails as PDF/EML/TXT",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.upload_file),
                      onPressed: () => _pickFiles(
                        (files) => setState(() => emailMessages = files),
                        allowedExtensions: ["pdf", "eml", "txt"],
                        allowMultiple: true,
                      ),
                    ),
                  ),

                  // 🎧 Call Recording
                  ListTile(
                    leading: const Icon(Icons.record_voice_over),
                    title: Text(
                      callRecordings.isEmpty
                          ? "Upload Call Recording"
                          : "${callRecordings.length} file(s) selected",
                    ),
                    subtitle: const Text("Audio/Video formats: MP3, WAV, MP4"),
                    trailing: IconButton(
                      icon: const Icon(Icons.upload_file),
                      onPressed: () => _pickFiles(
                        (files) => setState(() => callRecordings = files),
                        allowedExtensions: ["mp3", "wav", "mp4", "m4a"],
                        allowMultiple: true,
                      ),
                    ),
                  ),

                  // 📝 Call Transcript
                  ListTile(
                    leading: const Icon(Icons.text_snippet),
                    title: Text(
                      callTranscripts.isEmpty
                          ? "Upload Call Transcript"
                          : "${callTranscripts.length} file(s) selected",
                    ),
                    subtitle: const Text("Attach text/PDF transcripts"),
                    trailing: IconButton(
                      icon: const Icon(Icons.upload_file),
                      onPressed: () => _pickFiles(
                        (files) => setState(() => callTranscripts = files),
                        allowedExtensions: ["pdf", "doc", "docx", "txt"],
                        allowMultiple: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text("Submit Request"),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            if (summary != null) ...[
              const Text(
                "AI-generated Summary",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(summary!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
