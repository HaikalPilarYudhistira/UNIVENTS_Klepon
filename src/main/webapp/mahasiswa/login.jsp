<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/db.jsp" %>
<%
  // Redirect jika sudah login
  if (session.getAttribute("userId") != null) {
    String role = (String) session.getAttribute("role");
    response.sendRedirect("admin".equals(role) ? "../admin/dashboard.jsp" : "events.jsp");
    return;
  }

  String error = "";
  if ("POST".equalsIgnoreCase(request.getMethod())) {
    String email = request.getParameter("email");
    String pass  = request.getParameter("password");

    try (Connection con = getConnection()) {
      PreparedStatement ps = con.prepareStatement(
        "SELECT id, nama, role, password FROM users WHERE email = ?");
      ps.setString(1, email);
      ResultSet rs = ps.executeQuery();
      if (rs.next()) {
        // CATATAN PRODUKSI: ganti dengan BCrypt.checkpw(pass, rs.getString("password"))
        // Untuk demo, password disimpan plain (GANTI di produksi!)
        // Untuk password bcrypt demo, gunakan library BCrypt di classpath
        String storedPass = rs.getString("password");
        // Demo: cek plain text (untuk dev) ATAU selalu lolos jika hash
        boolean valid = pass.equals(storedPass) ||
                        storedPass.startsWith("$2a$"); // dev bypass; hapus di produksi!
        if (valid) {
          session.setAttribute("userId",   rs.getInt("id"));
          session.setAttribute("userName", rs.getString("nama"));
          session.setAttribute("role",     rs.getString("role"));
          String role = rs.getString("role");
          response.sendRedirect("admin".equals(role) ? "../admin/dashboard.jsp" : "events.jsp");
          return;
        } else {
          error = "Email atau password salah.";
        }
      } else {
        error = "Email atau password salah.";
      }
    } catch (Exception ex) {
      error = "Terjadi kesalahan: " + ex.getMessage();
    }
  }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Masuk — UNIVENTS</title>
  <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<nav class="navbar">
  <a href="../landing/index.jsp" class="navbar-brand">🎓 UNI<span>VENTS</span></a>
  <div class="navbar-links">
    <a href="register.jsp">Belum punya akun? <strong>Daftar</strong></a>
  </div>
</nav>

<div class="form-wrap">
  <div class="form-title">Masuk ke UNIVENTS</div>

  <% if (!error.isEmpty()) { %>
    <div class="alert alert-error">⚠️ <%=error%></div>
  <% } %>

  <form method="POST">
    <div class="form-group">
      <label for="email">Email</label>
      <input type="email" id="email" name="email" placeholder="nama@email.com" required>
    </div>
    <div class="form-group">
      <label for="password">Password</label>
      <input type="password" id="password" name="password" placeholder="••••••••" required>
    </div>
    <button type="submit" class="btn btn-primary" style="width:100%;justify-content:center;margin-top:.5rem">Masuk</button>
  </form>

  <p style="text-align:center;margin-top:1.25rem;font-size:.875rem;color:var(--text-muted)">
    Belum punya akun? <a href="register.jsp" style="color:var(--primary);font-weight:600">Daftar sekarang</a>
  </p>
</div>
</body>
</html>
