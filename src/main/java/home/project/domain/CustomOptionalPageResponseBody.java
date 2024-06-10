package home.project.domain;

import java.util.List;
import java.util.Optional;

public class CustomOptionalPageResponseBody<T> {
    public Result<T> result;
    public String responseMessage;
    public int status;

    public CustomOptionalPageResponseBody(Result<T> result, String responseMessage, int status) {
        this.result = result;
        this.responseMessage = responseMessage;
        this.status = status;
    }

    public static class Result<T> {
        public long totalCount;
        public int page;
        public Optional<List<T>> content;

        public Result(long totalCount, int page, Optional<List<T>> content) {
            this.totalCount = totalCount;
            this.page = page;
            this.content = content;
        }
    }
}

