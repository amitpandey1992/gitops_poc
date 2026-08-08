package com.gitops.taskflow.controller;

import com.gitops.taskflow.model.Task;
import com.gitops.taskflow.model.TeamMember;
import com.gitops.taskflow.service.TaskService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/tasks")
@RequiredArgsConstructor
public class TaskController {

    private final TaskService taskService;

    @GetMapping
    public String listTasks(@RequestParam(required = false) String status, Model model) {
        List<Task> tasks;
        if (status != null && !status.isBlank()) {
            tasks = taskService.getTasksByStatus(Task.Status.valueOf(status.toUpperCase()));
            model.addAttribute("filterStatus", status.toUpperCase());
        } else {
            tasks = taskService.getAllTasks();
        }
        model.addAttribute("tasks",      tasks);
        model.addAttribute("statuses",   Task.Status.values());
        model.addAttribute("pageTitle",  "Tasks");
        model.addAttribute("activePage", "tasks");
        return "tasks/list";
    }

    @GetMapping("/new")
    public String newTaskForm(Model model) {
        model.addAttribute("task",       new Task());
        model.addAttribute("members",    taskService.getAllMembers());
        model.addAttribute("statuses",   Task.Status.values());
        model.addAttribute("priorities", Task.Priority.values());
        model.addAttribute("pageTitle",  "New Task");
        model.addAttribute("activePage", "tasks");
        return "tasks/form";
    }

    @PostMapping("/new")
    public String createTask(@Valid @ModelAttribute Task task,
                             BindingResult result,
                             @RequestParam(required = false) Long assigneeId,
                             Model model,
                             RedirectAttributes redirectAttributes) {
        if (result.hasErrors()) {
            model.addAttribute("members",    taskService.getAllMembers());
            model.addAttribute("statuses",   Task.Status.values());
            model.addAttribute("priorities", Task.Priority.values());
            model.addAttribute("pageTitle",  "New Task");
            return "tasks/form";
        }
        if (assigneeId != null) {
            taskService.getMemberById(assigneeId).ifPresent(task::setAssignee);
        }
        taskService.createTask(task);
        redirectAttributes.addFlashAttribute("successMsg", "Task created successfully! ✅");
        return "redirect:/tasks";
    }

    @GetMapping("/{id}/edit")
    public String editTaskForm(@PathVariable Long id, Model model) {
        Task task = taskService.getTaskById(id)
                .orElseThrow(() -> new IllegalArgumentException("Task not found: " + id));
        model.addAttribute("task",       task);
        model.addAttribute("members",    taskService.getAllMembers());
        model.addAttribute("statuses",   Task.Status.values());
        model.addAttribute("priorities", Task.Priority.values());
        model.addAttribute("pageTitle",  "Edit Task");
        model.addAttribute("activePage", "tasks");
        model.addAttribute("editMode",   true);
        return "tasks/form";
    }

    @PostMapping("/{id}/edit")
    public String updateTask(@PathVariable Long id,
                             @Valid @ModelAttribute Task task,
                             BindingResult result,
                             @RequestParam(required = false) Long assigneeId,
                             Model model,
                             RedirectAttributes redirectAttributes) {
        if (result.hasErrors()) {
            model.addAttribute("members",    taskService.getAllMembers());
            model.addAttribute("statuses",   Task.Status.values());
            model.addAttribute("priorities", Task.Priority.values());
            model.addAttribute("editMode",   true);
            return "tasks/form";
        }
        if (assigneeId != null) {
            taskService.getMemberById(assigneeId).ifPresent(task::setAssignee);
        }
        taskService.updateTask(id, task);
        redirectAttributes.addFlashAttribute("successMsg", "Task updated successfully! ✅");
        return "redirect:/tasks";
    }

    @PostMapping("/{id}/delete")
    public String deleteTask(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        taskService.deleteTask(id);
        redirectAttributes.addFlashAttribute("successMsg", "Task deleted! 🗑️");
        return "redirect:/tasks";
    }

    // Team page
    @GetMapping("/team")
    public String teamPage(Model model) {
        model.addAttribute("members",    taskService.getAllMembers());
        model.addAttribute("pageTitle",  "Team");
        model.addAttribute("activePage", "team");
        return "tasks/team";
    }
}
