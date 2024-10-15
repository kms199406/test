package home.project.service;

import home.project.domain.Orders;
import home.project.dto.requestDTO.CreateOrderRequestDTO;
import home.project.dto.responseDTO.OrderResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface OrderService {
    OrderResponse join(CreateOrderRequestDTO createOrderRequestDTO);

    Orders findById(Long orderId);

    Page<OrderResponse> findAll(Pageable pageable);

    Page<OrderResponse> findOrders(String orderNum, String orderDate, String productNumber, String email, String content, Pageable pageable);

    OrderResponse findByIdReturnOrderResponse(Long orderId);

    String deleteById(Long orderId);
}