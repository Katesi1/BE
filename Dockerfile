FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 5285

ENV ASPNETCORE_URLS=http://+:5285
ENV ConnectionStrings__DefaultConnection="Server=host.docker.internal,1433;Database=BEApi;User Id=sa;Password=123456;Encrypt=False;TrustServerCertificate=True;Trusted_Connection=False;MultipleActiveResultSets=True;"
USER app
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG configuration=Release
WORKDIR /src
COPY ["BE-api.csproj", "./"]
RUN dotnet restore "BE-api.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "BE-api.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "BE-api.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "BE-api.dll"]
