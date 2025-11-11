part of 'model_check_cubit.dart';

abstract class ModelCheckState extends Equatable {
  const ModelCheckState();

  @override
  List<Object?> get props => [];
}

class ModelCheckInitial extends ModelCheckState {}

class ModelCheckLoading extends ModelCheckState {}

class ModelDownloaded extends ModelCheckState {
  final Set<String> downloaded;
  final Map<String, int> modelSizes; // in bytes

  const ModelDownloaded(this.downloaded, this.modelSizes);

  @override
  List<Object?> get props => [downloaded];
}

class ModelNotDownloaded extends ModelCheckState {}

class ModelCheckError extends ModelCheckState {
  final String message;

  const ModelCheckError(this.message);

  @override
  List<Object?> get props => [message];
}
