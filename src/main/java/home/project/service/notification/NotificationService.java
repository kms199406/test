package home.project.service.notification;

import home.project.domain.notification.Notification;
import home.project.dto.requestDTO.CreateNotificationRequestDTO;
import home.project.dto.responseDTO.NotificationDetailResponse;
import home.project.dto.responseDTO.NotificationResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface NotificationService {
     NotificationResponse createNotification(CreateNotificationRequestDTO createNotificationRequestDTO);

     Notification findById(Long notificationId);

    Page<NotificationResponse> findAllNotifications(Pageable pageable);

    NotificationDetailResponse findByIdReturnNotificationDetailResponse(Long notificationId);

    void deleteById(Long id);
}
