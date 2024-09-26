package home.project.dto.requestDTO;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.Check;

@Getter
@Setter
public class CreateProductRequestDTO {

    @NotBlank(message = "상품의 이름을 입력해주세요.")
    private String name;

    @NotBlank(message = "상품의 브랜드를 입력해주세요.")
    private String brand;

    @NotBlank(message = "상품의 카테고리를 입력해주세요.")
    private String category;

    private Long soldQuantity = 0L;

    @Check(name = "stock", constraints = "stock >= 0")
    @NotNull(message = "상품의 현재재고를 입력해주세요.")
    private Long stock;

}