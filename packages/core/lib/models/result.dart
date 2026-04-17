
sealed class Result<T> {
	const Result();

	R when<R>({
		required R Function(T value) success,
		required R Function(Exception error, StackTrace? stackTrace) failure,
	});
}


class Success<T> extends Result<T> {
	final T value;
	const Success(this.value);

	@override
	R when<R>({
		required R Function(T value) success,
		required R Function(Exception error, StackTrace? stackTrace) failure,
	}) {
		return success(value);
	}
}


class Failure<T> extends Result<T> {
	final Exception error;
	final StackTrace? stackTrace;
	const Failure(this.error, [this.stackTrace]);

	@override
	R when<R>({
		required R Function(T value) success,
		required R Function(Exception error, StackTrace? stackTrace) failure,
	}) {
		return failure(error, stackTrace);
	}
}
