package com.gitops.taskflow.service;

import com.gitops.taskflow.model.Task;
import com.gitops.taskflow.model.TeamMember;
import com.gitops.taskflow.repository.TaskRepository;
import com.gitops.taskflow.repository.TeamMemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class TaskService {

    private final TaskRepository taskRepository;
    private final TeamMemberRepository teamMemberRepository;

    // ── Dashboard Stats ──────────────────────────────────────────────────────

    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("total",      taskRepository.count());
        stats.put("todo",       taskRepository.countByStatus(Task.Status.TODO));
        stats.put("inProgress", taskRepository.countByStatus(Task.Status.IN_PROGRESS));
        stats.put("inReview",   taskRepository.countByStatus(Task.Status.IN_REVIEW));
        stats.put("done",       taskRepository.countByStatus(Task.Status.DONE));
        stats.put("teamSize",   teamMemberRepository.count());

        // Status breakdown for Chart.js
        List<Object[]> statusCounts = taskRepository.countGroupByStatus();
        Map<String, Long> statusChart = new LinkedHashMap<>();
        for (Task.Status s : Task.Status.values()) statusChart.put(s.name(), 0L);
        statusCounts.forEach(row -> statusChart.put(((Task.Status) row[0]).name(), (Long) row[1]));
        stats.put("statusChart", statusChart);

        // Priority breakdown for Chart.js
        List<Object[]> priorityCounts = taskRepository.countGroupByPriority();
        Map<String, Long> priorityChart = new LinkedHashMap<>();
        for (Task.Priority p : Task.Priority.values()) priorityChart.put(p.name(), 0L);
        priorityCounts.forEach(row -> priorityChart.put(((Task.Priority) row[0]).name(), (Long) row[1]));
        stats.put("priorityChart", priorityChart);

        // Recent 5 tasks
        stats.put("recentTasks", taskRepository.findAllByOrderByCreatedAtDesc()
                .stream().limit(5).toList());

        return stats;
    }

    // ── Task CRUD ────────────────────────────────────────────────────────────

    public List<Task> getAllTasks() {
        return taskRepository.findAllByOrderByCreatedAtDesc();
    }

    public List<Task> getTasksByStatus(Task.Status status) {
        return taskRepository.findByStatusOrderByCreatedAtDesc(status);
    }

    public Optional<Task> getTaskById(Long id) {
        return taskRepository.findById(id);
    }

    @Transactional
    public Task createTask(Task task) {
        return taskRepository.save(task);
    }

    @Transactional
    public Task updateTask(Long id, Task updated) {
        Task existing = taskRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Task not found: " + id));
        existing.setTitle(updated.getTitle());
        existing.setDescription(updated.getDescription());
        existing.setStatus(updated.getStatus());
        existing.setPriority(updated.getPriority());
        existing.setAssignee(updated.getAssignee());
        existing.setDueDate(updated.getDueDate());
        return taskRepository.save(existing);
    }

    @Transactional
    public void deleteTask(Long id) {
        taskRepository.deleteById(id);
    }

    // ── Team ─────────────────────────────────────────────────────────────────

    public List<TeamMember> getAllMembers() {
        return teamMemberRepository.findAll();
    }

    public Optional<TeamMember> getMemberById(Long id) {
        return teamMemberRepository.findById(id);
    }

    @Transactional
    public TeamMember saveMember(TeamMember member) {
        return teamMemberRepository.save(member);
    }
}
