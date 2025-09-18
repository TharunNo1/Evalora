enum RequestStage { submission, reviewInProgress, evaluation, sessionScheduled, completed }


class EvaluationRequest {
final String requestId;
final String startupId;
final RequestStage stage;


EvaluationRequest({required this.requestId, required this.startupId, required this.stage});
}