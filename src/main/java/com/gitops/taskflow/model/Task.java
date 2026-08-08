package com.gitops.taskflow.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "tasks")
@Data
@NoArgsConstructor
public class Task {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Title is required")
    @Size(max = 200)
    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Status status = Status.TODO;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Priority priority = Priority.MEDIUM;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assignee_id")
    private TeamMember assignee;

    private LocalDate dueDate;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;

    public enum Status {
        TODO, IN_PROGRESS, IN_REVIEW, DONE;

        public String getLabel() {
            return switch (this) {
                case TODO        -> "To Do";
                case IN_PROGRESS -> "In Progress";
                case IN_REVIEW   -> "In Review";
                case DONE        -> "Done";
            };
        }

        public String getBadgeClass() {
            return switch (this) {
                case TODO        -> "badge-todo";
                case IN_PROGRESS -> "badge-progress";
                case IN_REVIEW   -> "badge-review";
                case DONE        -> "badge-done";
            };
        }
    }

    public enum Priority {
        LOW, MEDIUM, HIGH, CRITICAL;

        public String getBadgeClass() {
            return switch (this) {
                case LOW      -> "priority-low";
                case MEDIUM   -> "priority-medium";
                case HIGH     -> "priority-high";
                case CRITICAL -> "priority-critical";
            };
        }
    }

    public boolean isOverdue() {
        return dueDate != null && dueDate.isBefore(LocalDate.now()) && status != Status.DONE;
    }
}
