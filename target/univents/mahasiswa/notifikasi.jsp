<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/db.jsp" %>
<%
  Integer userId = (Integer) session.getAttribute("userId");
  if (userId == null) { response.sendRedirect("login.jsp"); return; }
  String userName = (String) session.getAttribute("userName");

  // Tandai semua notif sebagai dibaca
  try (Connection con = getConnection()) {
    PreparedStatement upd = con.prepareStatement("UPDATE notifikasi SET dibaca=1 WHERE user_id=?");
    upd.setInt(1, userId); upd.executeUpdate();
  } catch (Exception ignored) {}

  StringBuilder notifHtml = new StringBuilder();
  try (Connection con = getConnection()) {
    PreparedStatement ps = con.prepareStatement(
      "SELECT pesan, dibaca, created_at FROM notifikasi WHERE user_id=? ORDER BY created_at DESC");
    ps.setInt(1, userId);
    ResultSet rs = ps.executeQuery();
    boolean any = false;
    while (rs.next()) {
      any = true;
      boolean dibaca = rs.getInt("dibaca") == 1;
      notifHtml.append("<div class='notif-item ").append(dibaca ? "" : "unread").append("'>")
               .append("<div class='notif-dot'></div>")
               .append("<div>")
               .append("<div style='font-size:.875rem'>").append(rs.getString("pesan")).append("</div>")
               .append("<div style='font-size:.75rem;color:var(--text-muted);margin-top:.25rem'>").append(rs.getTimestamp("created_at")).append("</div>")
               .append("</div></div>");
    }
    if (!any) notifHtml.append("<p style='color:var(--text-muted);text-align:center;padding:2rem'>Belum ada notifikasi.</p>");
  }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Notifikasi — UNIVENTS</title>
  <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<nav class="navbar">
  <a href="../landing/index.jsp" class="navbar-brand">🎓 UNI<span>VENTS</span></a>
  <div class="navbar-links">
    <a href="events.jsp">Event</a>
    <a href="notifikasi.jsp" class="active">🔔 Notifikasi</a>
    <span style="font-size:.875rem;color:var(--text-muted)"><%=userName%></span>
    <a href="logout.jsp" class="btn btn-outline btn-sm">Keluar</a>
  </div>
</nav>

<div class="container section" style="max-width:640px">
  <h1 style="font-size:1.4rem;font-weight:800;margin-bottom:1.5rem">🔔 Notifikasi Saya</h1>
  <div class="notif-list">
    <%=notifHtml%>
  </div>
</div>
</body>
</html>
