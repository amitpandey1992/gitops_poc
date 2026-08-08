package com.gitops.taskflow.repository;

import com.gitops.taskflow.model.Task;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public interface TaskRepository extends JpaRepository<Task, Long> {

    List<Task> findByStatusOrderByCreatedAtDesc(Task.Status status);

    List<Task> findByPriorityOrderByCreatedAtDesc(Task.Priority priority);

    List<Task> findAllByOrderByCreatedAtDesc();

    long countByStatus(Task.Status status);

    @Query("SELECT t.status, COUNT(t) FROM Task t GROUP BY t.status")
    List<Object[]> countGroupByStatus();

    @Query("SELECT t.priority, COUNT(t) FROM Task t GROUP BY t.priority")
    List<Object[]> countGroupByPriority();

    List<Task> findByAssigneeIdOrderByCreatedAtDesc(Long assigneeId);
}
