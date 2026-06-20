<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/db.jsp" %>
<%
  if (session.getAttribute("userId") != null) {
    response.sendRedirect("events.jsp"); return;
  }
  String error = "", success = "";
  if ("POST".equalsIgnoreCase(request.getMethod())) {
    String nama  = request.getParameter("nama");
    String nim   = request.getParameter("nim");
    String email = request.getParameter("email");
    String pass  = request.getParameter("password");
    String pass2 = request.getParameter("password2");

    if (!pass.equals(pass2)) {
      error = "Password tidak cocok.";
    } else if (pass.length() < 6) {
      error = "Password minimal 6 karakter.";
    } else {
      try (Connection con = getConnection()) {
        PreparedStatement check = con.prepareStatement("SELECT id FROM users WHERE email=? OR nim=?");
        check.setString(1, email); check.setString(2, nim);
        if (check.executeQuery().next()) {
          error = "Email atau NIM sudah terdaftar.";
        } else {
          PreparedStatement ins = con.prepareStatement(
            "INSERT INTO users (nama,nim,email,password,role) VALUES (?,?,?,?,'mahasiswa')");
          ins.setString(1, nama);
          ins.setString(2, nim);
          ins.setString(3, email);
          ins.setString(4, pass); // PRODUKSI: BCrypt.hashpw(pass, BCrypt.gensalt())
          ins.executeUpdate();
          success = "Akun berhasil dibuat! Silakan masuk.";
        }
      } catch (Exception ex) {
        error = "Terjadi kesalahan: " + ex.getMessage();
      }
    }
  }
%>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Daftar — UNIVENTS</title>
  <link rel="stylesheet" href="../css/style.css">
</head>
<body>
<nav class="navbar">
  <a href="../landing/index.jsp" class="navbar-brand">🎓 UNI<span>VENTS</span></a>
  <div class="navbar-links">
    <a href="login.jsp">Sudah punya akun? <strong>Masuk</strong></a>
  </div>
</nav>

<div class="form-wrap" style="max-width:500px">
  <div class="form-title">Buat Akun Mahasiswa</div>

  <% if (!error.isEmpty())   { %><div class="alert alert-error">⚠️ <%=error%></div><% } %>
  <% if (!success.isEmpty()) { %><div class="alert alert-success">✅ <%=success%> <a href="login.jsp" style="font-weight:600">Masuk →</a></div><% } %>

  <% if (success.isEmpty()) { %>
  <form method="POST">
    <div class="form-group">
      <label>Nama Lengkap</label>
      <input type="text" name="nama" placeholder="Nama Lengkap Anda" required>
    </div>
    <div class="form-row">
      <div class="form-group">
        <label>NIM</label>
        <input type="text" name="nim" placeholder="20240001" required>
      </div>
      <div class="form-group">
        <label>Email</label>
        <input type="email" name="email" placeholder="nama@mhs.ac.id" required>
      </div>
    </div>
    <div class="form-row">
      <div class="form-group">
        <label>Password</label>
        <input type="password" name="password" placeholder="Min. 6 karakter" required>
      </div>
      <div class="form-group">
        <label>Ulangi Password</label>
        <input type="password" name="password2" placeholder="Ulangi password" required>
      </div>
    </div>
    <button type="submit" class="btn btn-primary" style="width:100%;justify-content:center;margin-top:.5rem">Buat Akun</button>
  </form>
  <% } %>
</div>
</body>
</html>
